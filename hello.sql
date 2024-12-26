use marks

select * from chatgpt_daily_tweets;

select count(*)
from chatgpt_daily_tweets
where tweet_id is null

delete from chatgpt_daily_tweets where tweet_id is null

select cast(cast(tweet_extracted as datetimeoffset) as date) as tweet_extracted 
from chatgpt_daily_tweets

select cast(tweet_created as datetimeoffset) as tweet_created
from chatgpt_daily_tweets

update chatgpt_daily_tweets
set tweet_created = cast(format(cast(tweet_created as datetimeoffset), 'yyyy-MM-dd') as date)


update chatgpt_daily_tweets
set tweet_created = cast(tweet_created as date)

update chatgpt_daily_tweets
set tweet_extracted = cast(cast(tweet_extracted as datetimeoffset) as date)
--DECLARE @query nvarchar(max) = 'select tweet_created from chatgpt_daily_tweets';
--EXEC sp_describe_first_result_set @query, null, 0;  
