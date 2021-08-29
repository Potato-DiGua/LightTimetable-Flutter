# 服务器端

## 配置
### 开发环境
`server\src\main\resources\env\dev.properties`
```
# 数据库地址
jdbc_mysql_url=jdbc:mysql://test.example.com:3306/light_timetable
# redis地址
host=host.docker.internal
```
### 生产环境
`server\src\main\resources\env\prod.properties`
```
# 数据库地址
jdbc_mysql_url=jdbc:mysql://prod.example.com:3306/light_timetable
# redis地址
host=172.17.0.1
```
### 数据库
`server\src\main\resources\env\jdbc.properties`
```
# mysql用户名
jdbc_username=
# mysql密码
jdbc_pwd=
```

## 数据结构
建表sql在src/main/resources/schema-mysql.sql

## 服务器部署
`pom.xml`
```xml
<plugin>
    <groupId>com.google.cloud.tools</groupId>
    <artifactId>jib-maven-plugin</artifactId>
    <version>2.8.0</version>
    <configuration>
        <from>
            <!--<image>acukuj6n.mirror.aliyuncs.com/library/openjdk:8-jre-alpine</image>-->
            <!--          使用本地镜像              -->
            <image>docker://openjdk:8-jre-alpine</image>
        </from>
        <to>
            <image>填写私有仓库地址</image>
        </to>
        <container>
            <ports>
                <port>80</port>
            </ports>
            <creationTime>USE_CURRENT_TIMESTAMP</creationTime>
        </container>
    </configuration>
</plugin>
```
