use movie_db;
# Q1. Find all movies released after 2010 with a budget over $50M and IMDb vote average above 7.5
select
	original_title,
    release_date,
    budget,
    vote_average
from tmdb_movies
where year(release_date) > 2010 and  budget > 5000000 and vote_average > 7.50;

# Q2. List top 10 most popular movies with their revenue-to-budget ratio, ordered by ratio descending
select
	original_title,
    round(revenue/nullif(budget,0), 2) roi_ratio
from tmdb_movies
order by roi_ratio desc
limit 10;

# Q3. Find the average IMDb rating per genre from imdb_titles joined with imdb_ratings

# creating table to store the multiple genres in different rows
create table movie_genre_split(
	`tconst` varchar(12) NOT NULL,
	`titleType` varchar(20) DEFAULT NULL,
	`primaryTitle` varchar(500) DEFAULT NULL,
	`originalTitle` varchar(500) DEFAULT NULL,
	`isAdult` tinyint DEFAULT NULL,
	`startYear` smallint DEFAULT NULL,
	`endYear` smallint DEFAULT NULL,
	`runtimeMinutes` int DEFAULT NULL,
	`genres` varchar(200) DEFAULT NULL,
	key `idx_type` (`titleType`),
	key `idx_year` (`startYear`),
    key `idx_genre` (`genres`)
);

# Increasing limit for this query
set session cte_max_recursion_depth = 10000000;
set session max_execution_time = 0;

# insert the output of spliting genres
insert into movie_genre_split
with recursive SplitGenres as (
	   select 
		tconst, 
		trim(substring_index(genres, ',', 1)) as single_genre, 
		substring(genres, locate(',', genres) + 1) as remaining
	  from imdb_titles
	  where genres like '%,%'

	  union all

	  select 
		tconst, 
		trim(SUBSTRING_INDEX(remaining, ',', 1)), 
		if(locate(',', remaining) > 0, substring(remaining, locate(',', remaining) + 1), '')
	  from SplitGenres
	  where remaining <> ''
	)
	select 
		sg.tconst,
		it.titleType,
		it.primaryTitle, 
		it.originalTitle, 
		it.isAdult, 
		it.startYear, 
		it.endYear, 
		it.runtimeMinutes,
        TRIM(sg.single_genre) as genres
	from SplitGenres sg 
	join imdb_titles it on sg.tconst = it.tconst 
	order by tconst;
    
# Main query
select
	genres,
    count(*) total_movies
from movie_genre_split
group by genres
having count(*) >= 50
order by total_movies desc
limit 10;

# Q4. Identify publishers on Rotten Tomatoes who have the highest average review score, broken down by review type (Fresh/Rotten)
select
	publisher_name,
    review_type,
    count(review_type) Total_Reviews
from rt_reviews
where review_score is not null
group by publisher_name,review_type
order by count(*) desc
limit 10;

# Q5. List all movies that appear in both tmdb_movies and rt_movies, showing TMDB vote average vs RT tomatometer rating
select
	tm.title Title,
    tm.vote_average Vote_Avg,
    rm.tomatometer_rating TomatoMeter_Rating
from tmdb_movies tm
inner join rt_movies rm on rm.movie_title=tm.title
where rm.tomatometer_rating is not null;

# Q6. For each director in imdb_crew, show their total movies directed, average IMDb rating, and total votes accumulated
select
	ic.directors,
    inm.primaryName,
	count(*) count_movies,
    round(avg(ir.averageRating), 2) avg_imdb_rating,
    sum(ir.numVotes) total_votes,
    round(min(ir.averageRating), 2) min_imdb_rating,
    round(max(ir.averageRating), 2) max_imdb_rating
from imdb_crew ic
join imdb_names inm on ic.directors = inm.nconst
join imdb_titles it on ic.tconst = it.tconst
join imdb_ratings ir on it.tconst = ir.tconst
where
	it.titleType = 'movie'
    and ic.directors is not null
group by ic.directors, inm.primaryName
having count(*) >= 5
order by avg_imdb_rating desc
limit 10;