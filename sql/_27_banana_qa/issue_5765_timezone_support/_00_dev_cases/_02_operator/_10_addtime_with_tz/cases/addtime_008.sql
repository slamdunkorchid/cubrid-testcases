--TEST: pass marginal values of date/timestamptz/datetimetz type to the 1st param


--TEST: 1. marginal values: date argument
select addtime(date'0001-01-01', '9:19:29');

select addtime(date'9999-12-31', '9:19:29');

select addtime(date'12/31/9999', '9:19:29');

select addtime(date'1/1/1', '9:19:29');




--TEST: 2. marginal values: timestamptz argument
select addtime(timestamptz'00:00:00 01/01/01', '9:19:29');

select addtime(timestamptz'03:14:07 1/19/2038', '9:19:29');

select addtime(timestamptz'0:0:0 PM 1970-01-01', '9:19:29');

select addtime(timestamptz'1/19/2038 03:14:07', '9:19:29');



--TEST: 3. marginal values: datetimetz argument
select addtime(datetimetz'0:0:0.00 1/1/1', '9:19:29');

select addtime(datetimetz'23:59:59.999 12/31/9999', '9:19:29');

select addtime(datetimetz'00:00:00.0000 AM 0001-01-01', '9:19:29');

select addtime(datetimetz'12/31/9999 23:59:59.999', '0:0:0.000');

select addtime(datetimetz'12/31/9999 23:59:59.999', '0:0:0.001');



--TEST: 4. marginal values: timetz argument
select addtime('0:0:0.00', '9:19:29');

select addtime('23:59:59', '0:0:1');

select addtime('00:00:00', '9:19:29');

select addtime('23:59:59.999', '0:0:0.001');
