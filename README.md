# Docker compose for Magento 2 with multiple version.

## Build Docker Magento 2
1. Download Magento
    - Download magento by command line
        - How to add version magento to install
        
            1. If you want install multiple version magento to, you add version magento to variable `MAGENTO_VERSIONES` in file `.env` with format `version1,version2`.
                ```text
                MAGENTO_VERSIONES='2.1.1.15,2.2.6'
                ```
                
            2. Then, you must add copy file `docker-compose-magento-2.2.6-php-7.1.yml` to version corresponding: example `docker-compose-magento-2.1.15-php-7.0.yml`. 
            
                - Format in file docker compose as below
                ```text
                version: '3'
                
                services:
                  magento211570:
                    build:
                      context: ./magento
                      dockerfile: Dockerfile_7.0
                    container_name: docker-magento-multiple_magento_2.1.15_7.0_1
                    ports:
                      - 21157:80
                    depends_on:
                      - db
                    environment:
                      - MAGENTO_URL=http://magento21157.com:21157/
                      - MYSQL_DATABASE=magento21157
                    env_file:
                      - .env
                    volumes:
                      - ./src/2.1.15:/var/www/html
                    networks:
                      webnet:
                networks:
                  webnet:
                ```
                
            Note: 
            
                - File docker compose name with format: `docker-compose-magento-versionMagento-php-versionPhp.yml` 
                
        - Download source Magento
            ```bash
            ./bin/downloadMagento.sh
            ```
2. Build images
    ```bash
    ./bin/build.sh
    ```
3. Run service
    ```bash
    ./bin/run.sh #Run containers in the background, print new container names
    ```

## Stop service
```bash
./bin/stop.sh
```

## Remove service
```bash
./bin/remove.sh
```

### Note
- Docker: MariaDb, Phpmyadmin
    - Magento 2.2.6 + Php 7.1
    - Magento 2.1.3 + Php 7.0
    - Magento 2.1.15 + Php 7.0
- [Sample add version magento 2.1.3](https://github.com/FinbertMagestore/docker-magento-multiple/commit/a270a89445430f16d7e24231d2c3ae7cd08a7a0f)
- Links:
    - Magento 2.2.6: 
        - Frontend: http://magento22671.com:22671/
        - Backend: http://magento22671.com:22671/admin/
        
            Username: admin1
            
            Password: admin123
    - Magento 2.1.15: 
        - Frontend: http://magento21157.com:21157/
        - Backend: http://magento21157.com:21157/admin/
        
            Username: admin1
            
            Password: admin123
    - Magento 2.1.3: 
        - Frontend: http://magento21370.com:21370/
        - Backend: http://magento21370.com:21370/admin/
        
            Username: admin1
            
            Password: admin123
    - Phpmyadmin: http://localhost:2122/
- Source:
    - Download Magento 2: http://pubfiles.nexcess.net/magento/ce-packages/
    