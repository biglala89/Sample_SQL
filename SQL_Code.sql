# Nested CTE to determine good and bad salesmen
with total_items as (
  select salesman_id, 
          city_id, 
          sum(amount_earned) as earned_amt,
          sum(items_sold) as total_items_sold
  from daily_sales ds
  join salesman s
  on ds.salesman_id = s.id
  join city c
  on s.city_id = c.id
  group by salesman_id, city_id
  ), 
  
  city_average as (
    select city_id, 
            avg(earned_amt) as city_avg_earned
    from total_items
    group by city_id
    ),
  
  comparison as (
  select ca.city_id, 
          salesman_id, 
          earned_amt, 
          city_avg_earned,
          total_items_sold
  from city_average ca
  join total_items ti
  on ca.city_id = ti.city_id
  order by city_id
    )
    
select case when earned_amt > city_avg_earned then 'Good'
        else 'Bad' 
        end as label,
        avg(total_items_sold) as average
from comparison
group by label


# Show maximum average hours spent on a project with the client id
with h20 as (
  select project_id, count(distinct employee_id) as no_of_emp, sum(hours_spent) as total_hours
  from allocation
  group by 1
  having sum(hours_spent) > 20
  ),
  
  project_client as (
    select client_id, avg(no_of_emp) as avg_emp_num from h20
    join project p
    on p.id = h20.project_id
    group by 1
    )
    
    select avg_emp_num as maximal_average, client_id from project_client
    where avg_emp_num = (
      select max(avg_emp_num)
      from project_client
      )