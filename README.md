# BigData Query Using MySQL

This project demonstrates various SQL queries on a movie database combining data from IMDB, TMDB (The Movie Database), and Rotten Tomatoes.

## Dataset

The database `movie_db` contains the following tables:
- `tmdb_movies`: Movie data from TMDB including titles, budgets, revenues, ratings
- `imdb_titles`: Title information from IMDB
- `imdb_ratings`: Rating data from IMDB
- `imdb_crew`: Crew information including directors
- `imdb_names`: Names of people in the industry
- `rt_reviews`: Rotten Tomatoes reviews
- `rt_movies`: Rotten Tomatoes movie data
- `movie_genre_split`: Derived table for genre analysis (created in Q3)

## Prerequisites

- MySQL Server
- Access to the `movie_db` database with the above tables populated

## Queries

### Q1: High-Budget Movies After 2010 with High Ratings
Find all movies released after 2010 with a budget over $50M and IMDb vote average above 7.5.

```sql
select
    original_title,
    release_date,
    budget,
    vote_average
from tmdb_movies
where year(release_date) > 2010 and budget > 50000000 and vote_average > 7.50;
```

### Q2: Top 10 Movies by Revenue-to-Budget Ratio
List top 10 most popular movies with their revenue-to-budget ratio, ordered by ratio descending.

```sql
select
    original_title,
    round(revenue/nullif(budget,0), 2) roi_ratio
from tmdb_movies
order by roi_ratio desc
limit 10;
```

### Q3: Average IMDb Rating per Genre
Find the average IMDb rating per genre. This involves creating a table to split multi-genre entries.

First, create the `movie_genre_split` table and populate it using a recursive CTE to split genres.

Then, query for genres with at least 50 movies.

```sql
-- Table creation and population code here (from the file)
-- Main query:
select
    genres,
    count(*) total_movies
from movie_genre_split
group by genres
having count(*) >= 50
order by total_movies desc
limit 10;
```

### Q4: Top Publishers by Review Count on Rotten Tomatoes
Identify publishers with the highest number of reviews, broken down by review type (Fresh/Rotten).

```sql
select
    publisher_name,
    review_type,
    count(review_type) Total_Reviews
from rt_reviews
where review_score is not null
group by publisher_name, review_type
order by count(*) desc
limit 10;
```

### Q5: Movies in Both TMDB and Rotten Tomatoes
List movies that appear in both datasets, showing TMDB vote average vs RT tomatometer rating.

```sql
select
    tm.title Title,
    tm.vote_average Vote_Avg,
    rm.tomatometer_rating TomatoMeter_Rating
from tmdb_movies tm
inner join rt_movies rm on rm.movie_title = tm.title
where rm.tomatometer_rating is not null;
```

### Q6: Director Statistics
For each director, show total movies directed, average IMDb rating, total votes, min/max ratings (for directors with at least 5 movies).

```sql
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
```

## How to Run

1. Ensure MySQL is running and you have access to `movie_db`.
2. Execute the queries in order from the `IMDB BigData.sql` file.
3. Note: Q3 requires creating and populating the `movie_genre_split` table, which may take time due to the recursive CTE.

This project showcases advanced SQL techniques including joins, aggregations, CTEs, and data transformation for big data analysis. 
