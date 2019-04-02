# Docker compose for Magento 1 and 2 with multiple version.

## Docker Compose with
- Database
    - MariaDb
    - Phpmyadmin
- Web server: Apache2, Php
- Mailhog
- Varnish
- Cron
- RabbitMQ

## Cách sử dụng
- Yêu cầu phần cứng:
	- Cài đặt trên Ubuntu đã cài docker.
- File cấu hình: .env chứa thông tin config của toàn bộ repo gồm một số config quan trọng:
	- MAGENTO_VERSIONES: version của tất cả các phiên bản Mangeto, nếu cài đặt nhiều version thì các version cách nhau bởi dấu phẩy. Ví dụ: `MAGENTO_VERSIONES=2.2.5,2.2.6`, nếu chỉ cài đặt 1 version thì như ví dụ: `MAGENTO_VERSIONES=2.2.5` 
	- INSTALL_MAGENTO_WITH_DOMAIN: 
		- Giá trị là 1: install magento với domain được config với 2 tham số: MAGENTO_URL_PREFIX và MAGENTO_URL_TLD. Trong file .env magento sẽ được install ở domain: `http://m225.io`
		- Giá trị là 0: install magento với port.
	- Lưu ý: Các config trong file .env. True=1, False=0.
- Các file bash script trong folder `bin` có thể tham khảo ý nghĩa trong file `README_Dev.md`
- Install magento thì làm theo các bước sau:
	- Sửa file .env: config version magento.
	- Chạy lệnh cài đặt: 
		```bash
		./bin/main.sh
		```
	- Lưu ý: 
		- Tài khoản admin magento mặc định:
			```text
			admin1/admin123 (luôn có user này, thông tin được config trong file .env: MAGENTO_ADMIN_USERNAME và MAGENTO_ADMIN_PASSWORD)
			hoặc
			admin/admin123
			```
		- Cài đặt 1 version magento 1 lúc sẽ nhanh hơn.
		- Khi cài đặt nhiều version magento mà không sử dụng domain sẽ không thể đồng thời đăng nhập vào admin magento cùng lúc.
		- Sau khi cài 1 version magento, muốn cài đặt thêm 1 version magento khác đồng thời thì thêm version magento vào file `.env` với config `MAGENTO_VERSIONES` và chạy lại lệnh:
			```bash
			./bin/main.sh
			```
		- Sau khi đã cài magento 1 lần, muốn xóa magento và cài lại phải giữa nguyên config `MAGENTO_VERSIONES` và chạy lệnh xóa magento bên dưới, rồi mới sửa config `MAGENTO_VERSIONES` và install lại magento từ đầu.
		
			Do cấu trúc của project này lưu service của docker riêng biệt với từng version magento, lệnh xóa magento lấy các config `MAGENTO_VERSIONES` để lấy các file docker-compose cần thiết với các version magento.
			
		- Khi địa chỉ IP của server bị thay đổi. Nếu cài đặt magento sử dụng port thì cần lưu ý phải đổi lại url của magento bằng cách:
		```bash
		./bin/ssh.sh
		
		php bin/magento s:stor:set --base-url=<new_url>
		# php bin/magento s:stor:set --base-url=http://192.168.120.40:22571/
		
		php bin/magento c:f
		
		echo "Edit config in file app/etc/env.php about info: system > default > web > unsecure > base_url"
		# Edit config in file app/etc/env.php about info: system > default > web > unsecure > base_url
		
		php bin/magento s:up 
		# import config from file app/etc/env.php
		```
			
- Xóa magento thì chạy lệnh dưới để down container chạy magento và remove source code magento.
	```bash
	./bin/remove.sh
	```
	
- Tạm dừng docker đang chạy magento: 
	```bash
	./bin/stop.sh
	```
	Sau đó tiếp tục chạy lại magento thì start lại docker bằng lệnh
	```bash
	./bin/start.sh
	```
	Trong trường hợp server bị tắt mà động tự động chạy lại docker thì cũng chạy bằng lệnh trên để start lại docker mà không cần chạy lệnh install magento.

- SSH tới docker:
	```bash
	./bin/ssh.sh (với 1 version magento được install)
	./bin/ssh.sh <version_magento> <user_access> (với 1 version magento được install)
	# ./bin/ssh.sh 2.2.6 www-data
	# ./bin/ssh.sh 2.2.6 root
	```
	
- Folder chứa code Magento
	```bash
    source ./bin/common.sh && print_site_magento_list
    ```