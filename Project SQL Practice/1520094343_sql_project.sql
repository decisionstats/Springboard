/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
select * from country_club.Bookings;
select * from country_club.Facilities;
select * from country_club.Members;

select * from country_club.Facilities where membercost <> 0.0;  

/* Q2: How many facilities do not charge a fee to members? */
select count(*) from country_club.Facilities where membercost = 0.0;  

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
select facid,name,membercost,monthlymaintenance from country_club.Facilities 
where membercost < (monthlymaintenance*0.20); 

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
select * from country_club.Facilities where facid in (1,5); 

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
select name,monthlymaintenance,
case
	when monthlymaintenance > 100 then 'expensive' else 'cheap'
end as label
from country_club.Facilities 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
select firstname,surname from country_club.Members
where joindate in (select substr(max(joindate),1,10) from country_club.Members) 

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
select CONCAT(firstname,' ',surname) as name from country_club.Members where memid in (
select memid from country_club.Bookings where facid in
(select facid from country_club.Facilities where name in ('Tennis Court 1','Tennis Court 2'))
group by 1)
group by 1 

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
select name,CONCAT(firstname,' ',surname) as Mem_name, cost from
(select distinct A.memid, B.name, 
case
	when memid = 0 then guestcost*slots else membercost*slots
end as cost
FROM country_club.Bookings A, country_club.Facilities B
where A.facid = B.facid
and date(starttime) = '2012-09-14' 
) X, country_club.Members Y
where X.memid = Y.memid
and cost > 30
order by cost desc  

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select name,CONCAT(firstname,' ',surname) as Mem_name, cost from
(select A.memid, B.name, 
case
	when memid = 0 then guestcost*slots else membercost*slots
end as cost
FROM country_club.Bookings A 
INNER JOIN 
country_club.Facilities B
on A.facid = B.facid
and date(starttime) = '2012-09-14'
group by 1,2,3) X
INNER JOIN
(select memid,firstname,surname from country_club.Members) Y
on X.memid = Y.memid
where cost > 30
order by cost desc  

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT B.name as facility, SUM(
    CASE WHEN (A.memid > 0) 
        THEN 
          (slots * B.membercost) 
        ELSE 
          (slots * B.guestcost) 
       END) AS revenue 
  FROM 
       country_club.Bookings A INNER JOIN country_club.Facilities B ON
       A.facid = B.facid     
  GROUP BY B.name
  ORDER BY revenue 