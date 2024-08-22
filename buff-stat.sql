-- BP Statistics
SET @SCH = IF(VERSION()<'5.7','information_schema','performance_schema');

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @HOSTNAME        FROM ",@SCH,".global_variables WHERE variable_name='hostname'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @IBP_SIZE        FROM ",@SCH,".global_variables WHERE variable_name='innodb_buffer_pool_size'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @IBP_PAGES_DATA  FROM ",@SCH,".global_status    WHERE variable_name='Innodb_buffer_pool_pages_data'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @IBP_PAGES_FREE  FROM ",@SCH,".global_status    WHERE variable_name='Innodb_buffer_pool_pages_free'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @IBP_PAGES_MISC  FROM ",@SCH,".global_status    WHERE variable_name='Innodb_buffer_pool_pages_misc'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @IBP_PAGES_TOTAL FROM ",@SCH,".global_status    WHERE variable_name='Innodb_buffer_pool_pages_total'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @IBP_PAGE_SIZE   FROM ",@SCH,".global_status    WHERE variable_name='Innodb_page_size'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @IBP_PCT_DATA = 100.00 * @IBP_PAGES_DATA / @IBP_PAGES_TOTAL;
SET @IBP_PCT_FREE = 100.00 * @IBP_PAGES_FREE / @IBP_PAGES_TOTAL;
SET @IBP_PCT_MISC = 100.00 * @IBP_PAGES_MISC / @IBP_PAGES_TOTAL;
SET @IBP_PCT_FULL = 100.00 * (@IBP_PAGES_TOTAL - @IBP_PAGES_FREE) / @IBP_PAGES_TOTAL;

SET @initpad = 19;
SET @padding = IF(LENGTH(@HOSTNAME)>@initpad,LENGTH(@HOSTNAME),@initpad);
SET @decimal_places = 5; SET @KB = 1024; SET @MB = POWER(1024,2); SET @GB = POWER(1024,3);

SELECT       'innodb_buffer_pool_size' as 'Option',LPAD(FORMAT(@IBP_SIZE,0),@padding,' ') Value
UNION SELECT 'innodb_buffer_pool_size GB',LPAD(FORMAT(@IBP_SIZE / @GB,0),@padding,' ');

SELECT       'Hostname' Status                ,LPAD(@HOSTNAME,@padding,' ') Value
UNION SELECT 'This Moment'                    ,NOW()
UNION SELECT 'Innodb_page_size'               ,LPAD(FORMAT(@IBP_PAGE_SIZE,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_pages_data'  ,LPAD(FORMAT(@IBP_PAGES_DATA ,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_pages_free'  ,LPAD(FORMAT(@IBP_PAGES_FREE ,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_pages_misc'  ,LPAD(FORMAT(@IBP_PAGES_MISC ,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_pages_total' ,LPAD(FORMAT(@IBP_PAGES_TOTAL,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_bytes_data'  ,LPAD(FORMAT(@IBP_PAGES_DATA  * @IBP_PAGE_SIZE,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_bytes_free'  ,LPAD(FORMAT(@IBP_PAGES_FREE  * @IBP_PAGE_SIZE,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_bytes_misc'  ,LPAD(FORMAT(@IBP_PAGES_MISC  * @IBP_PAGE_SIZE,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_bytes_total' ,LPAD(FORMAT(@IBP_PAGES_TOTAL * @IBP_PAGE_SIZE,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_data GB'     ,LPAD(FORMAT(@IBP_PAGES_DATA  * @IBP_PAGE_SIZE / @GB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_free KB'     ,LPAD(FORMAT(@IBP_PAGES_FREE  * @IBP_PAGE_SIZE / @KB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_free MB'     ,LPAD(FORMAT(@IBP_PAGES_FREE  * @IBP_PAGE_SIZE / @MB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_free GB'     ,LPAD(FORMAT(@IBP_PAGES_FREE  * @IBP_PAGE_SIZE / @GB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_free GB'     ,LPAD(FORMAT(@IBP_PAGES_FREE  * @IBP_PAGE_SIZE / @GB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_misc KB'     ,LPAD(FORMAT(@IBP_PAGES_MISC  * @IBP_PAGE_SIZE / @KB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_misc MB'     ,LPAD(FORMAT(@IBP_PAGES_MISC  * @IBP_PAGE_SIZE / @MB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_misc GB'     ,LPAD(FORMAT(@IBP_PAGES_MISC  * @IBP_PAGE_SIZE / @GB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_total GB'    ,LPAD(FORMAT(@IBP_PAGES_TOTAL * @IBP_PAGE_SIZE / @GB,@decimal_places),@padding,' ')
UNION SELECT 'Percentage Data'                ,LPAD(CONCAT(FORMAT(@IBP_PCT_DATA,2),' %'),@padding,' ')
UNION SELECT 'Percentage Free'                ,LPAD(CONCAT(FORMAT(@IBP_PCT_FREE,2),' %'),@padding,' ')
UNION SELECT 'Percentage Misc'                ,LPAD(CONCAT(FORMAT(@IBP_PCT_MISC,2),' %'),@padding,' ')
UNION SELECT 'Percentage Used'                ,LPAD(CONCAT(FORMAT(@IBP_PCT_FULL,2),' %'),@padding,' ')
;

-- Calculate BP Hit Rate:
SET @buffer_pool_reads = (SELECT variable_value FROM performance_schema.global_status WHERE variable_name = 'Innodb_buffer_pool_reads');
SET @buffer_pool_read_requests = (SELECT variable_value FROM performance_schema.global_status WHERE variable_name = 'Innodb_buffer_pool_read_requests');

SELECT
    (@buffer_pool_read_requests - @buffer_pool_reads) / @buffer_pool_read_requests * 100 AS buffer_pool_hit_rate;
