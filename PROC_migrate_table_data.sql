-- This Proc is intends to migrate data from a table TABLE_TO_MIGRATE to a similar shadow table TABLE_TO_MIGRATE_SHADOW 
-- assuming there will be 'time' column
-- Parameters will be : fromDate, toDate - This range of data will be migrated (call it round), in batches of 'recordDurationHour' Hours data, with gap of 'gapInSec' secs in between.
-- Having a table 'migrationDebug' just for debigging purpose

DELIMITER $$

DROP PROCEDURE IF EXISTS `migrate_large_table_data`$$

CREATE PROCEDURE `migrate_large_table_data`(fromDate TIMESTAMP, toDate TIMESTAMP, recordDurationHour INT, gapInSec INT)
BEGIN
	DECLARE out_status TINYINT;
	DECLARE batchFromDate TIMESTAMP;
	DECLARE batchToDate TIMESTAMP;
	DECLARE batchStart TIMESTAMP;
	DECLARE roundStart TIMESTAMP;
	DECLARE batchCount INT;
	DECLARE roundCount INT;
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET out_status = 1;
	DECLARE EXIT HANDLER FOR NOT FOUND SET out_status = 1;
    
	-- Initialize
	SET batchStart = NOW();
	SET roundStart = NOW();
	SET batchToDate = fromDate;
	SET roundCount = 0;
	
	-- Debig Info
	INSERT INTO migrationDebug(type, time, fromDate, toDate, record, gapInSec) VALUES (1, NOW(), fromDate, toDate, recordDurationHour, gapInSec);
	-- Loop Starts
	insert_loop: LOOP
		IF batchToDate >= toDate THEN
			LEAVE insert_loop;
		ELSE
			SET batchFromDate = batchToDate;
			SET batchToDate = DATE_ADD(batchToDate, INTERVAL recordDurationHour HOUR);
		END IF;
		
		IF batchToDate > toDate THEN
			SET batchToDate = toDate;
		END IF;
		-- How many records are going to be moved in this Batch
		SELECT COUNT(1) INTO batchCount FROM TABLE_TO_MIGRATE WHERE time > batchFromDate AND time <= batchToDate;
		-- Total count of this round
		SET roundCount = roundCount + batchCount;
		
		-- Debug Info
		INSERT INTO migrationDebug(type, time, fromDate, toDate, record, gapInSec) VALUES (3, NOW(), batchFromDate, batchToDate, batchCount, (UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(batchStart)));
		SET batchStart = NOW();
		-- Copy data to shadow table
		INSERT INTO TABLE_TO_MIGRATE_SHADOW (<Columns_to_be_migrated>) (SELECT <Columns_to_be_migrated> FROM TABLE_TO_MIGRATE WHERE time > batchFromDate AND time <= batchToDate);
		
		-- Going to sleep now
		SELECT SLEEP(gapInSec);
	END LOOP insert_loop;
	-- Debug Info
	INSERT INTO migrationDebug(type, time, fromDate, toDate, record, gapInSec) VALUES (2, NOW(), fromDate, toDate, roundCount, (UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(roundStart)));
END$$

DELIMITER ;