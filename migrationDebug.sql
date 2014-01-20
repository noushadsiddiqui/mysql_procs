-- Debug table
CREATE TABLE `migrationDebug` (                                                  
	`type` TINYINT, -- 1 Proc Start, 2 Proc END, 3 Batch
	`time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,                                       
	`fromDate` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
	`toDate` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
	`record` INT DEFAULT NULL, 
	`gapInSec` INT DEFAULT NULL,
	KEY `IDX_MIGDEBUG_TYPE_TIME` (`type`,`time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8       