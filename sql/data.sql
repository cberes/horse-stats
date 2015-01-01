select e.finish_position, e.time, e.time_last_quarter, e.odds, e.horse_number,
hpe.odds as hp_odds, hpe.horse_number as hp_number, hpe.finish_position as hp_finish,
hpe.time as hp_time, hpe.time_last_quarter as hp_time_q4,
(julianday(r.started) - julianday(hpr.started)) / 86400.0 as horse_rest,
(julianday(r.started) - julianday(hpwr.started)) / 86400.0 as horse_cold,
hhd.min_time as hh_min_time, hhd.max_time as hh_max_time,
hhd.avg_time as hh_avg_time, hhd.min_time_q4 as hh_min_time_q4,
hhd.max_time_q4 as hh_max_time_q4, hhd.avg_time_q4 as hh_avg_time_q4,
hhd.count as hh_count, hhd.odds as hh_odds, hhd.finish_position as hh_finish,
hhd.avg_time - bhhd_time.avg_time as hh_time_diff,
hhd.finish_position - bhhd_pos.avg_finish as hh_pos_diff,
(COALESCE(julianday(hpwr.started), 0) - julianday(whhd_last_won.coldest_horse_last_won)) / 86400.0 as won_time_diff,
(COALESCE(julianday(hpr.started), 0) - julianday(whhd_last_raced.coldest_horse_last_raced)) / 86400.0 as raced_time_diff
from race r
join entry e on e.race_id = r._id
join horse h on h._id = e.horse_id
join person d on d._id = e.driver_id
join person t on t._id = e.trainer_id
-- horse's previous race
left outer join entry hpe on hpe._id in (
select ee._id from entry ee
join race rr on rr._id = ee.race_id
where ee.horse_id = h._id and rr.started < r.started
order by rr.started desc
limit 1
)
left outer join race hpr on hpr._id = hpe.race_id
-- horse's previous win
left outer join entry hpwe on hpwe._id in (
select ee._id from entry ee
join race rr on rr._id = ee.race_id
where ee.horse_id = h._id and rr.started < r.started and ee.finish_position = 1
order by rr.started desc
limit 1
)
left outer join race hpwr on hpwr._id = hpwe.race_id
-- driver's previous race
left outer join entry dpe on dpe._id in (
select ee._id from entry ee
join race rr on rr._id = ee.race_id
where ee.driver_id = d._id and rr.started < r.started
order by rr.started desc
limit 1
)
left outer join race dpr on dpr._id = dpe.race_id
-- driver's previous win
left outer join entry dpwe on dpwe._id in (
select ee._id from entry ee
join race rr on rr._id = ee.race_id
where ee.driver_id = d._id and rr.started < r.started and ee.finish_position = 1
order by rr.started desc
limit 1
)
left outer join race dpwr on dpwr._id = dpwe.race_id
-- trainer's previous race
left outer join entry tpe on tpe._id in (
select ee._id from entry ee
join race rr on rr._id = ee.race_id
where ee.trainer_id = t._id and rr.started < r.started
order by rr.started desc
limit 1
)
left outer join race tpr on tpr._id = tpe.race_id
-- trainer's previous win
left outer join entry tpwe on tpwe._id in (
select ee._id from entry ee
join race rr on rr._id = ee.race_id
where ee.trainer_id = t._id and rr.started < r.started and ee.finish_position = 1
order by rr.started desc
limit 1
)
left outer join race tpwr on tpwr._id = tpwe.race_id
-- horse's historical data
join (
select ee.horse_id, rr._id as race_id,
min(ee1.time) / 1000.0 as min_time, max(ee1.time) / 1000.0 as max_time,
avg(ee1.time) / 1000.0 as avg_time, min(ee1.time_last_quarter) / 1000.0 as min_time_q4,
max(ee1.time_last_quarter) / 1000.0 as max_time_q4, avg(ee1.time_last_quarter) / 1000.0 as avg_time_q4,
count(ee1._id) as count, avg(ee1.odds) as odds, avg(ee1.finish_position) as finish_position
from race rr
join entry ee on ee.race_id = rr._id
join entry ee1 on ee1.horse_id = ee.horse_id and ee1.race_id <> ee.race_id
and ee1.time not null and ee1.time > 0
and ee1.time_last_quarter not null and ee1.time_last_quarter > 0
join race rr1 on ee1.race_id = rr1._id and rr1.started < rr.started
group by rr._id, ee.horse_id
) hhd on hhd.horse_id = h._id and hhd.race_id = r._id
-- other horses' best average time
left outer join (select horse_id, race_id, min(avg_time) as avg_time from (
select ee.horse_id, rr._id as race_id, avg(ee1.time) / 1000.0 as avg_time
from race rr
join entry ee on ee.race_id = rr._id
join entry ee_o on ee_o.race_id = ee.race_id and ee_o.horse_id <> ee.horse_id
join entry ee1 on ee1.horse_id = ee_o.horse_id and ee1.race_id <> ee_o.race_id
and ee1.time not null and ee1.time > 0
and ee1.time_last_quarter not null and ee1.time_last_quarter > 0
join race rr1 on ee1.race_id = rr1._id and rr1.started < rr.started
-- need to group by other horse's ID, otherwise all are averaged together
group by rr._id, ee.horse_id, ee1.horse_id
) z group by race_id, horse_id) bhhd_time on bhhd_time.horse_id = h._id and bhhd_time.race_id = r._id
-- other horses' best average finish position
left outer join (select horse_id, race_id, min(avg_finish) as avg_finish from (
select ee.horse_id, rr._id as race_id, avg(ee1.finish_position) as avg_finish
from race rr
join entry ee on ee.race_id = rr._id
join entry ee_o on ee_o.race_id = ee.race_id and ee_o.horse_id <> ee.horse_id
join entry ee1 on ee1.horse_id = ee_o.horse_id and ee1.race_id <> ee_o.race_id
and ee1.time not null and ee1.time > 0
and ee1.time_last_quarter not null and ee1.time_last_quarter > 0
join race rr1 on ee1.race_id = rr1._id and rr1.started < rr.started
-- need to group by other horse's ID, otherwise all are averaged together
group by rr._id, ee.horse_id, ee1.horse_id
) z group by race_id, horse_id) bhhd_pos on bhhd_pos.horse_id = h._id and bhhd_pos.race_id = r._id
-- find the time of the horse's win who won least recently
left outer join (
select race_id, horse_id, min(last_won) as coldest_horse_last_won from (
select e.race_id, e.horse_id, eo.horse_id as other_horse_id, max(r1.started) as last_won
from race r
join entry e on e.race_id = r._id
join entry eo on eo.race_id = e.race_id and eo.horse_id <> e.horse_id
join entry e1 on e1.horse_id = eo.horse_id and e1.finish_position = 1
join race r1 on r1._id = e1.race_id and r1.started < r.started
group by e.race_id, e.horse_id, eo.horse_id) z
group by race_id, horse_id
) whhd_last_won on whhd_last_won.horse_id = h._id and whhd_last_won.race_id = r._id
-- find the time of the horse's race who raced least recently
left outer join (
select race_id, horse_id, min(last_raced) as coldest_horse_last_raced from (
select e.race_id, e.horse_id, eo.horse_id as other_horse_id, max(r1.started) as last_raced
from race r
join entry e on e.race_id = r._id
join entry eo on eo.race_id = e.race_id and eo.horse_id <> e.horse_id
join entry e1 on e1.horse_id = eo.horse_id
join race r1 on r1._id = e1.race_id and r1.started < r.started
group by e.race_id, e.horse_id, eo.horse_id) z
group by race_id, horse_id
) whhd_last_raced on whhd_last_raced.horse_id = h._id and whhd_last_raced.race_id = r._id
-- filter
where r.location_id = 1
and r.started > CAST(strftime('%s', '2014-03-01') AS INT)
order by r.started desc;

-- for horse, driver, and trainer:
-- days since last win
-- time/q4/finish of last start
-- odds
-- number
-- days since last race
-- average time
-- average q4 time
-- number of previous starts
