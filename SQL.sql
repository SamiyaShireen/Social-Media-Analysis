use ig_clone;

--                     OBJECTIVE ANSWER 1
--    Finding duplicate values
SELECT username, COUNT(*) FROM users
GROUP BY username
HAVING COUNT(*) > 1;

SELECT *, COUNT(*) FROM comments
GROUP BY id
HAVING COUNT(*) > 1;

SELECT *, COUNT(*) FROM follows
GROUP BY followee_id,follower_id
HAVING COUNT(*) > 1;

--   Finding Null Values
SELECT * FROM users
WHERE id IS NULL OR username IS NULL OR created_at IS NULL;

SELECT * FROM follows
WHERE followee_id IS NULL OR follower_id IS NULL OR created_at IS NULL;

SELECT * FROM comments
WHERE id IS NULL OR comment_text IS NULL OR user_id IS NULL OR photo_id IS NULL
OR created_at IS NULL;

SELECT * FROM likes
WHERE user_id IS NULL OR photo_id IS NULL OR created_at IS NULL;

SELECT * FROM photo_tags
WHERE photo_id IS NULL OR tag_id IS NULL;

SELECT * FROM photos
WHERE id IS NULL OR image_url IS NULL OR user_id IS NULL OR created_dat IS NULL;

SELECT * FROM tags
WHERE id IS NULL OR tag_name IS NULL OR created_at IS NULL;

--   To handle null values
SELECT COALESCE(column_name, 'default_value') AS default_column
FROM table_name;


--                    OBJECTIVE ANSWER 2
SELECT u.id AS user_id,
       u.username,
       COUNT(p.id) AS total_posts,
       COALESCE(SUM(l.user_id IS NOT NULL), 0) AS total_likes
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON p.id = l.photo_id
GROUP BY u.id, u.username
ORDER BY total_posts DESC
LIMIT 50;


--                   OBJECTIVE ANSWER 3
-- To calculate the average number of tags per post:
WITH TagCounts AS (
    SELECT photo_id, COUNT(*) AS tag_count
    FROM photo_tags
    GROUP BY photo_id)
SELECT AVG(tag_count) AS avg_tags_per_post
FROM TagCounts;   
   

--                   OBJECTIVE  ANSWER 4
--  To rank users by engagement (likes, comments) on their posts:
WITH UserEngagement AS (
    SELECT u.id AS user_id,u.username,COUNT(p.id) AS total_posts,
        COALESCE(SUM(l.likes_count), 0) AS total_likes,
        COALESCE(SUM(c.comments_count), 0) AS total_comments,
        CASE 
            WHEN COUNT(p.id) > 0 THEN 
                (COALESCE(SUM(l.likes_count), 0) + COALESCE(SUM(c.comments_count), 0)) / COUNT(p.id)
            ELSE 0 
        END AS engagement_rate
    FROM users u
    JOIN photos p ON u.id = p.user_id
    JOIN 
        (SELECT photo_id, COUNT(*) AS likes_count FROM likes GROUP BY photo_id) l ON p.id = l.photo_id
    JOIN 
        (SELECT photo_id, COUNT(*) AS comments_count FROM comments GROUP BY photo_id) c ON p.id = c.photo_id
    GROUP BY u.id
)
SELECT user_id,username,total_posts,total_likes,total_comments,engagement_rate,
    ROW_NUMBER() OVER (ORDER BY engagement_rate DESC) AS `rank`
FROM UserEngagement
ORDER BY `rank`;

--               OBJECTIVE ANSWER 5
--  To find users with the highest number of followers and followings:
WITH follower_counts AS (
    SELECT u.id, COUNT(f.follower_id) AS follower_count
    FROM users u
    JOIN follows f ON u.id = f.followee_id
    GROUP BY u.id
),
following_counts AS (
    SELECT u.id, COUNT(f.followee_id) AS following_count
    FROM users u
	JOIN follows f ON u.id = f.follower_id
    GROUP BY u.id
)
SELECT fc.id, 
       (SELECT username FROM users WHERE id = fc.id) AS username,
       fc.follower_count, 
       fn.following_count
FROM follower_counts fc
JOIN following_counts fn ON fc.id = fn.id
ORDER BY fc.follower_count DESC, fn.following_count DESC
LIMIT 10; 


--                   OBJECTIVE ANSWER 6
--   The average engagement rate per post for each user as follows:
SELECT
    u.id AS user_id,u.username,
    COUNT(p.id) AS total_posts,
    COALESCE(SUM(l.likes_count), 0) AS total_likes,
    COALESCE(SUM(c.comments_count), 0) AS total_comments,
    (COALESCE(SUM(l.likes_count), 0) + COALESCE(SUM(c.comments_count), 0)) / NULLIF(COUNT(p.id), 0) 
    AS avg_engagement_per_post
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
JOIN (
    SELECT photo_id,COUNT(*) AS likes_count
    FROM likes
    GROUP BY photo_id) l ON p.id = l.photo_id
 JOIN (
    SELECT photo_id,COUNT(*) AS comments_count
    FROM comments
    GROUP BY photo_id) c ON p.id = c.photo_id
GROUP BY u.id, u.username
LIMIT 10;


--                 OBJECTIVE ANSWER 7
--   Users never liked any post
SELECT u.id,u.username
FROM users u
WHERE u.id NOT IN (
    SELECT l.user_id
    FROM likes l)
LIMIT 10;
	

--              OBJECTIVE ANSWER 8
-- User Engagement Analysis
SELECT u.id AS user_id,
       u.username,
       COUNT(p.id) AS total_posts,
       COALESCE(SUM(l.user_id IS NOT NULL), 0) AS total_likes
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON p.id = l.photo_id
GROUP BY u.id, u.username
ORDER BY total_posts DESC
LIMIT 50;

-- Content Popularity by Tags
SELECT t.tag_name,Count(t.tag_name) AS "tags count"
FROM  tags t
INNER JOIN photo_tags ph ON t.id = ph.tag_id
GROUP  BY t.tag_name
ORDER  BY Count(t.tag_name) DESC
; 


--              OBJECTIVE ANSWER 9
-- User Engagement Analysis
SELECT u.id AS user_id,
       u.username,
       COUNT(p.id) AS total_posts,
       COALESCE(SUM(l.user_id IS NOT NULL), 0) AS total_likes
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON p.id = l.photo_id
GROUP BY u.id, u.username
ORDER BY total_posts DESC
LIMIT 50;

--              OBJECTIVE ANSWER 10
SELECT u.id,u.username,
    COALESCE(sub1.TotalLikes, 0) AS TotalLikes,
    COALESCE(sub2.TotalComments, 0) AS TotalComments,
    COALESCE(sub3.TotalPhotoTags, 0) AS TotalPhotoTags
FROM users u
LEFT JOIN (
    -- Subquery to calculate total likes per user
    SELECT l.user_id,COUNT(*) AS TotalLikes
    FROM likes l
    JOIN photos p ON l.photo_id = p.user_id
    GROUP BY l.user_id
)sub1 ON u.id = sub1.user_id
JOIN (
    -- Subquery to calculate total comments per user
    SELECT c.user_id,COUNT(*) AS TotalComments
    FROM comments c
    JOIN photos p ON c.photo_id = p.user_id
    GROUP BY c.user_id
) sub2 ON u.id= sub2.user_id
JOIN (
    -- Subquery to calculate total photo tags per user
    SELECT p.user_id,COUNT(pt.tag_id) AS TotalPhotoTags
    FROM photos p
    JOIN photo_tags pt ON p.user_id = pt.photo_id
    GROUP BY p.user_id
) sub3 ON u.id = sub3.user_id;


--                OBJECTIVE ANSWER 11
--  Ranking users on their total engagement
WITH engagement_data AS (
    SELECT u.id,u.username,
        COUNT(DISTINCT l.photo_id) AS total_likes,
        COUNT(DISTINCT c.id) AS total_comments
    FROM users u
    LEFT JOIN photos p ON u.id = p.user_id
    LEFT JOIN likes l ON p.user_id = l.photo_id
    LEFT JOIN comments c ON p.user_id = c.photo_id
    WHERE 
        p.created_dat >= DATE_FORMAT(CURRENT_DATE, '%Y-%m-01') AND 
    p.created_dat < DATE_FORMAT(CURRENT_DATE + INTERVAL 1 MONTH, '%Y-%m-01')
    GROUP BY u.id, u.username
),
total_engagement AS (
    SELECT id,username,(total_likes + total_comments) AS total_engagement
    FROM engagement_data
)
SELECT id,username,total_engagement,
    RANK() OVER (ORDER BY total_engagement DESC) AS engagement_rank
FROM total_engagement
ORDER BY engagement_rank;


--                OBJECTIVE ANSWER 12
WITH hashtag_likes AS (
  SELECT h.tag_name as hashtag_name,AVG(l.photo_id) as avg_likes
  FROM photos p
  join likes l on p.user_id=l.photo_id
  JOIN photo_tags pt ON l.photo_id = pt.photo_id
  JOIN tags h ON pt.tag_id = h.id
  GROUP BY h.tag_name
)
SELECT hashtag_name,avg_likes
FROM hashtag_likes
ORDER BY avg_likes DESC
LIMIT 10;


--              OBJECTIVE ANSWER 13
SELECT u1.username AS follower
FROM users u1
JOIN follows f ON u1.id = f.follower_id
JOIN users u2 ON f.followee_id = u2.id
WHERE 
  NOT EXISTS (
    SELECT 1
    FROM follows
    WHERE follower_id = u2.id AND followee_id = u1.id);



--              SUBJECTIVE ANSWER  1
SELECT u.id,u.username,
    COALESCE(likes_count.likes_given, 0) AS likes_given,
    COALESCE(photos_count.photos_uploaded, 0) AS photos_uploaded,
    COALESCE(followers_count.follower_count, 0) AS follower_count,
    (COALESCE(likes_count.likes_given, 0) * 0.5 + 
     COALESCE(photos_count.photos_uploaded, 0) * 0.3 + 
     COALESCE(followers_count.follower_count, 0) * 0.2) AS engagement_score
FROM users u
JOIN (
    SELECT user_id, COUNT(photo_id) AS likes_given 
    FROM likes 
    GROUP BY user_id
) likes_count ON u.id = likes_count.user_id
JOIN (
    SELECT user_id, COUNT(id) AS photos_uploaded 
    FROM photos 
    GROUP BY user_id
) photos_count ON u.id = photos_count.user_id
JOIN (
    SELECT followee_id, COUNT(follower_id) AS follower_count 
    FROM follows 
    GROUP BY followee_id
) followers_count ON u.id = followers_count.followee_id
ORDER BY engagement_score DESC
LIMIT 10;

--              SUBJECTIVE ANSWER 2
SELECT u.id,u.username,COUNT(p.user_id) AS 'no._of_posts'
FROM  users u
LEFT JOIN photos p ON u.id = p.user_id
GROUP  BY u.id
;


--              SUBJECTIVE ANSWER 3
SELECT t.tag_name,Count(t.tag_name) AS "tags count"
FROM  tags t
INNER JOIN photo_tags ph ON t.id = ph.tag_id
GROUP  BY t.tag_name
ORDER  BY Count(t.tag_name) DESC
; 


--             SUBJECTIVE ANSWER 4
SELECT 
    HOUR(p.created_dat) AS posting_hour,
	DATE(p.created_dat) AS posting_date,
    COUNT(p.id) AS total_photos_posted,
    COUNT(l.user_id) AS total_likes,
    COUNT(c.id) AS total_comments
FROM photos p
LEFT JOIN likes l ON p.id = l.photo_id
LEFT JOIN comments c ON p.id = c.photo_id
GROUP BY posting_hour,posting_date
ORDER BY total_likes DESC, total_comments DESC;


--             SUBJECTIVE ANSWER 5
SELECT u.id,u.username,COUNT(f.follower_id) AS follower_count,
    COALESCE(SUM(l.likes_count), 0) AS total_likes,
    COALESCE(SUM(c.comments_count), 0) AS total_comments,
    (COALESCE(SUM(l.likes_count), 0) + COALESCE(SUM(c.comments_count), 0)) AS total_engagements,
    (COALESCE(SUM(l.likes_count), 0) + COALESCE(SUM(c.comments_count), 0)) * 100.0 / COUNT(f.follower_id)
    AS engagement_rate
FROM users u
LEFT JOIN follows f ON u.id = f.follower_id
LEFT JOIN (
    SELECT photo_id, COUNT(*) AS likes_count
    FROM likes
    GROUP BY photo_id
) l ON u.id = l.photo_id
LEFT JOIN (
    SELECT photo_id, COUNT(*) AS comments_count
    FROM comments
    GROUP BY photo_id
) c ON u.id = c.photo_id
GROUP BY u.id, u.username
HAVING follower_count >= 50
ORDER BY engagement_rate DESC  
LIMIT 10;
 

--              SUBJECTIVE ANSWER 6
SELECT u.id, u.username, 
    COUNT(p.id) AS total_photos, 
    COUNT(l.photo_id) AS total_likes,
    COUNT(c.id) AS total_comments,
    CASE 
        WHEN COUNT(p.id) > 10000 AND COUNT(l.photo_id) > 10000 AND COUNT(c.id) > 10000 THEN 'High Engagement'
        WHEN COUNT(p.id) BETWEEN 1000 AND 10000 AND COUNT(l.photo_id) BETWEEN 1000 AND 10000 AND
        COUNT(c.id) BETWEEN 1000 AND 10000 THEN 'Medium Engagement'
        ELSE 'Low Engagement'
    END AS engagement_level
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON p.id = l.photo_id
LEFT JOIN comments c ON p.id = c.photo_id 
GROUP BY u.id, u.username;


--              SUBJECTIVE ANSWER 7
SELECT 
    campaign_id,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    SUM(revenue) AS total_revenue,
    SUM(cost) AS total_cost,
    CASE 
        WHEN SUM(impressions) > 0 THEN (SUM(clicks) * 100.0 / SUM(impressions)) 
        ELSE 0 
    END AS ctr,
    CASE 
        WHEN SUM(clicks) > 0 THEN (SUM(conversions) * 100.0 / SUM(clicks)) 
        ELSE 0 
    END AS conversion_rate,
    CASE 
        WHEN SUM(cost) > 0 THEN ((SUM(revenue) - SUM(cost)) * 100.0 / SUM(cost)) 
        ELSE 0 
    END AS roi
FROM ad_campaigns
WHERE campaign_date >= DATE_TRUNC('month', CURRENT_DATE) 
GROUP BY campaign_id
ORDER BY campaign_id;


--             SUBJECTIVE ANSWER 8
-- Top Engaged Users
SELECT u.id, u.username, COUNT(l.photo_id) AS total_likes
FROM users u
JOIN likes l ON u.id = l.user_id
GROUP BY u.id
ORDER BY total_likes DESC
LIMIT 10;

-- Content creators
SELECT u.id, u.username, COUNT(p.id) AS total_photos
FROM users u
JOIN photos p ON u.id = p.user_id
GROUP BY u.id
ORDER BY total_photos DESC
LIMIT 10;

-- Influencer Identification
SELECT u.id, u.username, COUNT(f.follower_id) AS followers
FROM users u
JOIN follows f ON u.id = f.followee_id
GROUP BY u.id
HAVING followers > 10
ORDER BY followers DESC;


--              SUBJECTIVE ANSWER 10
UPDATE User_Interactions
SET Engagement_Type = 'Heart'
WHERE Engagement_Type = 'Like';


















 



