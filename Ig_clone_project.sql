use ig_clone

select * from comments
select * from follows
select * from likes
select * from photo_tags
select * from photos
select * from tags
select * from users



*//Q1--How many times does the average user post//*

select round(avg((select count(*) from photos)/(select count(*) from users)),3) as avgrage
from users


*//Q2--Find the top 5 most used hashtags//*

select tag_name, count(tag_id) as total from tags as t
inner join  photo_tags as pt 
ON t.id = pt.tag_id
group by  tag_id
order by total DESC
limit 5;



*//Q3--Find users who have liked every single photo on the site//*

select user_id,users.username ,count(user_id) as total_likes from likes 
inner join users 
on users.id=likes.user_id
group by user_id
having total_likes=(select count(*) from photos)
order by user_id;


*//Q4--Retrieve a list of users along with their usernames and the rank of their account creation
	   ordered by the creation date in ascending order//*
       
select *, rank() over(order by created_at) as creation_date_rank from users;



*//Q5--List the comments made on photos with their comment texts, photo URLs, and
       usernames of users who posted the comments.
       Include the comment count for each photo//*

select  comments.user_id, username, comment_text, image_url,
count(*) over( partition by photo_id)  as comment_count
from comments
inner join photos 
on comments.user_id=photos.user_id
inner join users
on users.id=photos.user_id
order by comments.user_id;



*//Q6--For each tag, show the tag name and the number of photos associated with that tag.
       Rank the tags by the number of photos in descending order//*
 
select distinct  tag_name, count(photo_id) over (partition by tag_name )as tag_count,
rank() over( partition by count(photo_id) order by tag_name desc)  as tag_rank,
dense_rank() over(partition by count(photo_id) order by tag_name desc)  as tag_rank_d
from tags t 
inner join photo_tags pg
on pg.tag_id=t.id
group by  tag_name,photo_id;


*//Q7--List the usernames of users who have posted photos along with the count of photos they have posted.
	   Rank them by the number of photos in descending order//*

select distinct user_id,username,  count(image_url)   as IM,
rank() over (order by count(image_url) desc ) as ranks from users
inner join photos 
on photos.user_id=users.id
group by user_id, username;



*//Q8--Display the username of each user along with the creation date of their first posted
       photo and the creation date of their next posted photo//*

**//version-1//**
select distinct username ,
(select date(p.created_at) from photos 
order by date(p.created_at)
limit 1) as fisrt_date,
(select date(p.created_at) from photos 
order by date(p.created_at)
limit 1 offset 1) as second_date
from photos p
inner join users u
on u.id=p.user_id;

**//version-2//*
select  username , min(date(p.created_at)) as first_post_date,
(select date(p.created_at) from photos 
order by date(p.created_at)
limit 1,1)
as second_post_date
from users as u
inner join photos as p
on p.user_id=u.id
group by username, p.created_at;

*//Q9--For each comment, show the comment text, the username of the commenter,
       and the comment text of the previous comment made on the same photo//*
 
select  username ,photo_id,  comment_text,
lag(comment_text ,1) over(partition by photo_id) as prev_com
from comments as c
inner join users as u 
on u.id=c.user_id
order by photo_id;




 
 *//Q10--Show the username of each user along with the number of photos they have posted 
		and the number of photos posted by the user before them and after them,
		based on the creation date//*
 

select  user_id, username , count(*) over ( partition by user_id) as counts,
lag(p.user_id) over (partition by user_id order by p.created_at) as lags ,
lead(p.user_id) over ( partition by user_id order by p.created_at) as leads 
from photos as p 
inner join users as u 
on u.id=p.user_id
group by username ,image_url, p.created_at 
order by user_id;