SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for calendar_table
-- ----------------------------
DROP TABLE IF EXISTS `calendar_table`;
CREATE TABLE `calendar_table`
(
    `uuid`     int(11)                                                NOT NULL AUTO_INCREMENT,
    `userid`   int(11)                                                NOT NULL,
    `term`     varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
    `calendar` json                                                   NOT NULL,
    PRIMARY KEY (`uuid`) USING BTREE,
    INDEX `search__index` (`userid`, `term`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for shared_table
-- ----------------------------
DROP TABLE IF EXISTS `shared_table`;
CREATE TABLE `shared_table`
(
    `userId`   int(11)                                             NOT NULL,
    `key`      char(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
    `calendar` json                                                NOT NULL,
    PRIMARY KEY (`userId`) USING BTREE,
    UNIQUE INDEX `shared_table_key_uindex` (`key`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_table
-- ----------------------------
DROP TABLE IF EXISTS `user_table`;
CREATE TABLE `user_table`
(
    `id`       int(11)                                                 NOT NULL AUTO_INCREMENT,
    `account`  varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL,
    `userName` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL,
    `password` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL,
    `icon`     varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `user_table_username_uindex` (`userName`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci
  ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;

