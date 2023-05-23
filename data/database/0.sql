DROP TABLE IF EXISTS `options`;
DROP TABLE IF EXISTS `links`;

CREATE TABLE `options` (
    `name` VARCHAR( 255 ) NOT NULL PRIMARY KEY,
	`value` TEXT NULL
);

INSERT INTO `options` (`name`, `value`)
	VALUES ('version', 0);

CREATE TABLE `links` (
    `short` VARCHAR( 255 ) NOT NULL PRIMARY KEY,
	`target` VARCHAR( 1000 ) NOT NULL
);
