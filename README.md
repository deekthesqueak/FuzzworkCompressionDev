Setup Steps


1. git clone git@github.com:deekthesqueak/compression.git
2. cd compression
3. docker run --rm --interactive --tty --volume $PWD:/app composer install
4. cd ../
5. curl https://www.fuzzwork.co.uk/dump/mysql-latest.tar.bz2 --output mysql-latest.tar.bz2
6. tar xvf mysql-latest.tar.bz2 --strip 1
7. mv sde-<date>-TRANQUILITY.sql sql/sde-latest.sql
8. docker-compose up -d
9. http://localhost:8765/compression