# Docker compose for Magento 2 with multiple version.

## Build Docker Magento 2
1. Download Magento
    - Download magento by command line
        - Edit magento version and magento sample data version in file `.env`. 
        
            If you want install multiple version magento to, you add version to variable `MAGENTO_VERSIONES` with format `version1,version2`.
            ```text
            MAGENTO_VERSIONES='2.1.1.15,2.2.6'
            ```
             
            Then, you must add copy file `docker-compose-magento-2.2.6-php-7.1.yml` to version corresponding: example `docker-compose-magento-2.1.15-php-7.0.yml`. 
            
            Note: 
            
            - File docker compose name with format: `docker-compose-magento-versionMagento-php-versionPhp.yml` 
            - Format in file docker compose as
            ```text
            version: '3'
            
            services:
              magento22671:
                build:
                  context: ./magento
                  dockerfile: Dockerfile_7.1
                ports:
                  - 22671:80
                depends_on:
                  - db
                environment:
                  - MAGENTO_URL=http://magento22671.com:22671/
                  - MYSQL_DATABASE=magento22671
                env_file:
                  - .env
                volumes:
                  - ./src/2.2.6:/var/www/html
                networks:
                  webnet:
            networks:
              webnet:
            ```
            ```bash
            ./bin/downloadMagento.sh
            ```
2. Build images
    ```bash
    ./bin/build.sh
    ```
3. Run service
    ```bash
    ./bin/run.sh #Run containers, show output to console
    ./bin/run.sh -d #Run containers in the background, print new container names
    ```
4. Provide permission edit for user `www-data` to in docker container folder `/var/www/html`
    ```bash
    docker exec -it docker-magento-multiple_magento22671_1 bash
    ```
    ```bash
    chown -R www-data:www-data .
    chmod -R 777 .
    ```
5. Install magento 2
    ```bash
    docker exec -it -u www-data docker-magento-multiple_magento22671_1 bash
    ./install_magento.sh 
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
    - Magento 2.1.15 + Php 7.0
- Links:
    - Magento 2.2.6: 
        - Frontend: http://magento22671.com:22671/
        - Backend: http://magento22671.com:22671/admin/
        
            Username: admin
            
            Password: admin123
    - Magento 2.1.15: 
        - Frontend: http://magento21570.com:21570/
        - Backend: http://magento21570.com:21570/admin/
        
            Username: admin
            
            Password: admin123
    - Phpmyadmin: http://localhost:2122/
- Source:
    - Download Magento 2: http://pubfiles.nexcess.net/magento/ce-packages/
    