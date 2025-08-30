select * from campaigns;
select * from donations;
select * from donors;

-- Client KPI----

-- # How much money has been raised in Total?

select sum(donation_amount) as Total_Amount
from donations;

-- # Which payment method is most preffred?

select payment_mode, sum(donation_amount) as total_amount
from donations
group by payment_mode
order by total_amount desc;


-- # Who are the biggest donors?

select name, sum(donation_amount) as total_donated
from donations as d
join donors as dr on dr.donor_id = d.donor_id
group by name
order by total_donated desc;

-- # Which campaign has the best ROI?

select c.campaign_name, 
	   sum(donation_amount) as total_raised,
       c.expenses,
	      (sum(donation_amount) - c.expenses) *100 / c.expenses as ROI_percent
from campaigns as c 
join donations as d on d.campaign_id = c.campaign_id
group by c.campaign_name, c.expenses
order by ROI_percent desc;


-- # Which city contributed the most?

select d.location, sum(dr.donation_amount) as total_amount
from donors as d
join donations as dr on dr.donor_id = d.donor_id
group by d.location
order by total_amount desc;


-- # How much of total fundraising came from reccuring donors?

select donor_type, sum(donation_amount) as total_amount
from donors as d
join donations as dr on dr.donor_id = d.donor_id
where donor_type = 'Recurring'
group by donor_type
order by total_amount desc; 


-- # Which campaign met or missed the fundraising goals?

select c.campaign_name, c.fundraising_goal,
       sum(dr.donation_amount) as total_raised,
       case
           when sum(dr.donation_amount) >= fundraising_goal then 'Goal Achieved'
           else 'Goal Missed'
		   end as 'Status'
from campaigns as c 
join donations as dr on dr.campaign_id = c.campaign_id
group by c.campaign_name, c.fundraising_goal;



-- # Find top 3 donors by Total contribution?

with Donortotal as (
	select d.donor_id, d.name, sum(donation_amount) as total_amount
    from donations as dr
    join donors as d on d.donor_id = dr.donor_id
    group by d.donor_id, d.name
)
select name, total_amount
from Donortotal
order by total_amount desc
limit 3;    

-- # Calculate ROI inside CTE and then rank Campaign?

with campaignROI as (
select c.campaign_name, 
sum(dr.donation_amount) as total_amount, c.expenses,
  (sum(dr.donation_amount) - c.expenses) * 100.0 / c.expenses as ROI_percent
from campaigns as c 
join donations as dr on dr.campaign_id = c.campaign_id
group by c.campaign_name, c.expenses
)
select campaign_name, total_amount, expenses, ROI_percent,
      Rank() over (order by ROI_percent desc) as ROI_rank
from campaignROI;






 
           