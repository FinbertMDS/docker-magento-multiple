# Docker compose for Magento 1 and 2 with multiple version.

## Build Docker Magento
1. If you want install multiple version magento to, you add version magento to variable `MAGENTO_VERSIONES` in file `.env` with format `version1,version2`.
    ```text
    MAGENTO_VERSIONES='2.2.7,2.3.0'
    ```
    
    - Note: If you only install a version Magento: example `2.3.0` and you want install more quicker than, you can change file `docker-compose.yml` at `services` -> `db` from:
        ```text
          db:
            build: ./data
        #    image: ngovanhuy0241/docker-magento-multiple-db
            container_name: docker-magento-multiple_db_1
        ```
        
        to
        
        ```text
          db:
        #    build: ./data
            image: ngovanhuy0241/docker-magento-multiple-db:2.3.0
            container_name: docker-magento-multiple_db_1
        ``` 
        
        This above had include in bash script `bin/prepare` function `prepare_environment_for_once_version_magento`. You only need change version on file `.env` environment `MAGENTO_VERSIONES` with once version magento. 
2. Run command to install Magento
    ```bash
    ./bin/main.sh
    ```

## Some bash in folder bin
1. `bin/common.sh`: Some function used for other script.
2. `bin/main.sh`: Run when create and start container first time: download magento, then build, then start container.
3. `bin/download_magento.sh`: Download source to install magento
4. `bin/build.sh`: Build all images.
5. `bin/run.sh`: Run images to containers and start its in background from first time.
6. `bin/start.sh`: Run all container stared before now, start its in background from second time.
7. `bin/stop.sh`: Stop all container which running in background.
8. `bin/remove.sh`: Stop and remove all container what started by docker compose
9. `bin/ssh.sh`: Ssh to docker container what containers contain magento and contain database.
10. `bin/backup_database.sh`: Backup all databases which not backup before now to file.

## Build image to [Docker Hub](https://hub.docker.com)
### ngovanhuy0241/docker-magento-multiple-magento
- With version new of PHP 7.2
    1. Create file `docker-compose-magento-php-7.2-build.yml`
    2. Create file `magento/Dockerfile_7.2`
    3. Create file `magento/Dockerfile_image_7.2`
    4. Build image
        ```bash
        docker-compose -f docker-compose-magento-php-7.2-build.yml build
        ```
    5. Push image to Docker Hub
        ```bash
        docker login
        docker tag docker-magento-multiple_php72 ngovanhuy0241/docker-magento-multiple-magento:php72
        docker push ngovanhuy0241/docker-magento-multiple-magento:php72
        ```

### ngovanhuy0241/docker-magento-multiple-db
1. https://github.com/FinbertMagestore/docker-magento-multiple-db/tree/develop

## Note
- Docker: MariaDb, Phpmyadmin
    - Magento 2.2.x
        - 2.2.1
        - 2.2.6
        - 2.2.7        
    - Magento 2.1.x
        - 2.1.15
        - 2.1.16
        - 2.1.3        
    - Magento 1.x 
        - 1.9.3.10
- [Sample add version magento 2.1.3](https://github.com/FinbertMagestore/docker-magento-multiple/commit/a270a89445430f16d7e24231d2c3ae7cd08a7a0f)
- Links:
    - Magento:
        - Run command below to show all link to version magento
            ```bash
            source ./bin/common.sh && print_site_magento_list
            ```
    - Phpmyadmin: http://localhost:2122/
    - MailHog: http://localhost:8025/
- Source:
    - Download Magento 2: http://pubfiles.nexcess.net/magento/ce-packages/    
