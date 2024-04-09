-- total trips
select count(tripid) as total_trips from trips_details;

-- total drivers
select count( distinct driverid) as total_drivers from trips;

-- total earnings
select sum(fare) as total_earnings from trips;

-- total Completed trips
select count(tripid) as total_trips from trips_details
where end_ride=1;

-- total searches
select count(searches) as total_searches from trips_details;

-- total searches which got estimate
select count(searches_got_estimate) from trips_details
where searches_got_estimate=1;

-- total searches for quotes
select count(searches_for_quotes) from trips_details
where searches_for_quotes=1;

-- total searches which got quotes
select count(searches_got_quotes) from trips_details
where searches_got_estimate=1;

-- total driver cancelled
select count(driver_not_cancelled) from trips_details
where driver_not_cancelled=0;

-- total otp entered
select count(otp_entered) from trips_details
where otp_entered=1;

-- total end ride
select count(end_ride) from trips_details
where end_ride=1;

-- cancelled bookings by driver
select count(driver_not_cancelled) from trips_details
where driver_not_cancelled=0;

-- cancelled bookings by customer
select count(customer_not_cancelled) from trips_details
where customer_not_cancelled=0;

-- average distance per trip
select avg(distance) from trips;

-- average fare per trip
select avg(fare) from trips;

-- distance travelled
select sum(distance) from trips;

-- which is the most used payment method 
select p.method,count(t.faremethod)as count
from trips t 
inner join payment p 
on t.faremethod=p.id
group by p.method
order by count desc
limit 1;

-- the highest payment was made through which method 
with cte as
(select p.method,t.fare as highest_payment,
dense_rank() over(order by t.fare desc) as rnk
from trips t 
inner join payment p on t.faremethod=p.id
order by t.fare desc
)
select method, highest_payment
from cte 
where rnk=1;

-- which two locations pair had the most trips
with locations as(select 
l1.assembly1 as area_from,l2.assembly1 as area_to,count(distinct tripid) as most_trips,
rank() over(order by count(distinct tripid) desc) as rnk
from trips t 
inner join loc l1
on t.loc_from=l1.id 
inner join loc l2
on t.loc_to=l2.id 
where l1.id<>l2.id
group by l1.assembly1,l2.assembly1
)
select area_from,area_to,most_trips
from locations
where rnk<3;

-- top 5 earning drivers
with cte as(select driverid,sum(fare) as earning,
dense_rank() over(order by sum(fare) desc) as rnk
from trips
group by driverid)
select driverid,earning
from cte 
where rnk<6;

-- which duration had more trips
select d.duration,count(t.tripid) as most_trips
from trips t 
inner join duration d 
on t.duration=d.id
group by d.duration
order by most_trips desc
limit 1;

-- which driver , customer pair had most trips
with c as(select driverid,custid,count(tripid) as total,
dense_rank() over(order by count(tripid) desc) as rnk
from trips
group by driverid,custid
)
select  driverid,custid, total
from c
where rnk=1
;

-- search to estimate rate
select sum(searches_got_estimate)/sum(searches)*100 from trips_details;

-- estimate to search for quote rates
select sum(searches_for_quotes)/sum(searches_got_estimate)*100 from trips_details;

-- quote acceptance rate
select sum(searches_got_quotes)/sum(searches_for_quotes)*100 from trips_details;


-- quote to booking rate
select (sum(searches_got_estimate)/sum(searches_for_quotes))*100 from trips_details;


-- booking cancellation rate
SELECT round((COUNT(*) - SUM(customer_not_cancelled)) * 100.0 / COUNT(*),2) AS cancellation_rate_percentage
FROM trips_details;


-- conversion rate
select round(sum(end_ride) * 100.0 / sum(searches),2) as conversion_rate_percentage
from trips_details;


-- which area got highest trips in which duration
select l.assembly1 as area ,d.duration,count(t.tripid) as total_trips
from trips t 
inner join loc l on t.loc_from=l.id
inner join duration d on t.duration=d.id
group by l.assembly1,d.duration
order by total_trips desc
limit 1;

-- which area got the highest fares
select l.assembly1 as area ,sum(t.fare) as total_fare
from trips t 
inner join loc l on t.loc_from=l.id
group by l.assembly1
order by total_fare desc 
limit 1;

-- which area got the highest trips
select l.assembly1 as area ,count(t.tripid) as total_trips
from trips t 
inner join loc l on t.loc_from=l.id
group by l.assembly1
order by total_trips desc 
limit 1;

-- which area got the highest cancellation
with cte as(
select loc_from,count(*)- sum(customer_not_cancelled) as cancellation
from trips_details
group by loc_from
order by cancellation desc
)
select l.assembly1 as area , cte.cancellation as cancelled
from cte
inner join loc l
on cte.loc_from=l.id 
order by cancelled desc
limit 1;

-- which duration got the highest trips and fares
select d.duration,count(tripid) as total_trips 
from trips t 
inner join duration d
on t.duration=d.id
group by d.duration
order by total_trips desc
limit 1;

-- Conversion_rate = calculate(sum(Merge2[end_ride])/sum(Merge2[searches]))


