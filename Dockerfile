FROM python:3.7-alpine3.14

WORKDIR /app

COPY ./requirements.txt /app/requirements.txt

# upgrade pip
RUN python -m pip install --upgrade pip

RUN apk add --no-cache \
    lapack \
    libstdc++ \
    ca-certificates \
    tzdata \
    redis \
    bash \
    libjpeg \
    libpng \
    libwebp \
    tiff \
    openblas

# install python requirements
RUN apk add --no-cache --virtual .build-deps \
    g++ \
    make \
    cmake \
    gcc \
    lapack-dev \
    gfortran \
    libjpeg-turbo-dev \
    libpng-dev \
    tiff-dev \
    libwebp-dev \
    freetype-dev \
    libexecinfo-dev \
    openblas-dev \
    libgomp \
    libffi-dev \
    python3-dev \
    openssl-dev \
    libexecinfo-dev \
    freetype-dev \
    libquadmath && \
    pip install --no-cache-dir -r /app/requirements.txt && \
    apk del .build-deps

# install tlsh
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    g++ \
    cmake \
    make \
    wget && \
    mkdir -p /tmp/tlsh && \
    wget https://github.com/trendmicro/tlsh/archive/refs/tags/4.8.2.tar.gz -O /tmp/tlsh/source.tar.gz && \
    tar --strip-components=1 -xf /tmp/tlsh/source.tar.gz && \
    ./make.sh && \
    cd py_ext/ && \
    python ./setup.py build && \
    python ./setup.py install && \
    cd ../Testing && \
    ./python_test.sh && \
    cd /tmp && \
    rm -rf /tmp/tlsh

COPY ./carlhauser_server /app/carlhauser_server
COPY ./carlhauser_client/API/extended_api.py /app/carlhauser_client/API/extended_api.py
COPY ./carlhauser_client/API/simple_api.py /app/carlhauser_client/API/simple_api.py
COPY ./carlhauser_client/Helpers/dict_utilities.py /app/carlhauser_client/Helpers/dict_utilities.py
COPY ./carlhauser_client/logging.ini /app/carlhauser_client/logging.ini
COPY ./carlhauser_client/cert.pem /app/carlhauser_client/cert.pem
COPY ./common /app/common
COPY ./start.sh /app/start.sh

ENV CARLHAUSER_HOME /app/
ENV PYTHONPATH /app/

VOLUME [ "/app/storage", "/app/carlhauser_server/Data/database_data" ]

EXPOSE 443

CMD [ "./start.sh" ]

