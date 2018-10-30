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