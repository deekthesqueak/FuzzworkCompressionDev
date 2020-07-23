FROM debian:jessie AS ext-lpsolve

RUN apt-get update && apt-get install -y \
        make \
        lp-solve \
        php5-dev \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/lib/lp_solve/liblpsolve55.so /usr/lib && ldconfig -v

RUN curl -o lp_solve_5.5.2.5_source.tar.gz -L https://sourceforge.net/projects/lpsolve/files/lpsolve/5.5.2.5/lp_solve_5.5.2.5_source.tar.gz/download 
RUN curl -o lp_solve_5.5.2.5_PHP_source.tar.gz -L https://sourceforge.net/projects/lpsolve/files/lpsolve/5.5.2.5/lp_solve_5.5.2.5_PHP_source.tar.gz/download 
RUN tar zxvf lp_solve_5.5.2.5_source.tar.gz && tar zxvf lp_solve_5.5.2.5_PHP_source.tar.gz
RUN mv lp_solve_5.5 /usr/lib
RUN cd /usr/lib/lp_solve_5.5/lpsolve55/ && chmod +x ccc && ./ccc
RUN cd /usr/lib/lp_solve_5.5/lp_solve/ && chmod +x ccc && ./ccc
RUN ln -s /usr/lib/lp_solve_5.5/lpsolve55/bin/ux64/liblpsolve55.so /usr/lib/liblpsolve5.5.so
COPY PHP_56.patch /usr/lib/lp_solve_5.5/extra/PHP
RUN patch -u /usr/lib/lp_solve_5.5/extra/PHP/PHPmod.c -i /usr/lib/lp_solve_5.5/extra/PHP/PHP_56.patch
# Patch for PHP 5.6 https://github.com/myfarms/php_lp_solve/commit/3ea1d4f284734b0f5010c7f4f28748c8d7844809
RUN cd /usr/lib/lp_solve_5.5/extra/PHP/ && phpize && ./configure --with-phplpsolve55=../.. && make && make test
RUN ln -s /usr/lib/lp_solve_5.5/extra/PHP/modules/phplpsolve55.so /usr/lib/php5/20131226/phplpsolve5.5.so

FROM php:5.6-apache
RUN apt-get update && apt-get install -y \
        lp-solve \
    && rm -rf /var/lib/apt/lists/* 
COPY --from=ext-lpsolve /usr/lib/liblpsolve5.5.so /usr/lib/liblpsolve5.5.so
COPY --from=ext-lpsolve /usr/lib/php5/20131226/phplpsolve5.5.so /usr/lib/phplpsolve5.5.so
RUN ldconfig -v
RUN echo 'date.timezone="America/Los_Angeles"' >> /usr/local/etc/php/conf.d/00_datetime.ini
RUN echo "extension=/usr/lib/phplpsolve5.5.so" >> /usr/local/etc/php/conf.d/30-lp_solve.ini

RUN docker-php-ext-install -j$(nproc) pdo pdo_mysql