create or replace function z_insert_employee()
returns setof void as $$
declare
  l_id int;
  l_room_no smallint;
  l_ktp_no numeric;
  l_name_first varchar;
  l_name_last varchar;
  l_join_date timestamp without time zone;
  l_basic_pay money;
  l_random_day smallint;
  l_start_day day;
  l_random_work_cond smallint;
  l_working_condition working_condition;
begin
  select trunc(random() * 1000000 + 1000000) into l_id;
  select trunc(random() * 100 + 1) into l_room_no;
  select trunc(random() * 10000000000000000 + 10000000000000000) into l_ktp_no;
  select substring(md5(random()::text) from 1 for 8) into l_name_first;
  select substring(md5(random()::text) from 1 for 8) into l_name_last;
  select timestamp '1999-01-01 08:00:00' + random() * interval '17 years' into l_join_date;
  select trunc(random() * 1500000 + 10000000) into l_basic_pay;

  select trunc(random() * 5 + 1) into l_random_day;
  case l_random_day
  when 1 then l_start_day='Monday';
  when 2 then l_start_day='Tuesday';
  when 3 then l_start_day='Wednesday';
  when 4 then l_start_day='Thursday';
  when 5 then l_start_day='Friday';
  end case;

  select trunc(random() *2 + 1) into l_random_work_cond;
  case l_random_work_cond
  when 1 then l_working_condition='Permanent';
  when 2 then l_working_condition='Contract';
  end case;

  insert into employees(id, room_no, ktp_no, name_first, name_last, join_date, basic_pay, start_day, working_condition)
    values(l_id, l_room_no, l_ktp_no, l_name_first, l_name_last, l_join_date, l_basic_pay, l_start_day, l_working_condition);
return;
end; $$ language plpgsql;
