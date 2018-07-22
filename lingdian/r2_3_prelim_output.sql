
#staymonth中的条目筛选
#fx.date, fx.uid, fx.gender, fx.age, fx.prov_id, fx.ptype, fx.stime, fx.etime, fx.gw, fx.lat, fx.lon, fx.spot

#prov, profile (sumdate) count #5555
select x2.prov_id, x2.sumdate, count(1) as n from 
(select x.uid, x.prov_id, sum(x.date) as sumdate from 
(select uid, date, prov_id from temp_ldf0720_smsel3 group by uid, date, prov_id) x
group by x.uid, x.prov_id) x2
group by x2.prov_id, x2.sumdate;

#prov, spot, profile (gender, age, sumdate) count #5554
select x.prov_id, x.gender, x.age, x.spot, x.sumdate, count(1) as n from
(select x1.uid, x1.prov_id, x1.gender, x1.age, x1.spot, sum(x1.date) as sumdate from
(select uid, date, prov_id, gender, age, spot from temp_ldf0720_smsel3 group by date, uid, prov_id, gender, age, spot) x1
group by x1.uid, x1.prov_id, x1.gender, x1.age, x1.spot) x
group by x.prov_id, x.gender, x.age, x.spot, x.sumdate;

#prov, profile count #5556
select x.prov_id, x.gender, x.age, x.sumdate, count(1) as n from
(select x1.uid, x1.prov_id, x1.gender, x1.age, sum(x1.date) as sumdate from
(select uid, date, prov_id, gender, age from temp_ldf0720_smsel3 group by date, uid, prov_id, gender, age) x1
group by x1.uid, x1.prov_id, x1.gender, x1.age) x
group by x.prov_id, x.gender, x.age, x.sumdate;

#check r #5557
select x.prov_id, x.r, count(1) as n from
(select x1.uid, x1.prov_id, count(1) as r from
(select uid, spot, prov_id, gender, age from temp_ldf0720_smsel3
where spot is not null
group by spot, uid, prov_id, gender, age) x1
group by x1.uid, x1.prov_id) x
group by x.prov_id, x.r;

#check r #5560
select x.prov_id, x.r, x.countdate, count(1) as n from
(select x1.uid, x1.prov_id, count(distinct x1.date) as countdate, count(1) as r from
(select uid, date, spot, prov_id, gender, age from temp_ldf0720_smsel3
where spot is not null
group by spot, date, uid, prov_id, gender, age) x1
group by x1.uid, x1.prov_id) x
group by x.prov_id, x.r, x.countdate;

#spots #5561
select x2.prov_id, x2.n, count(1) as n2 from 
(
select x1.uid, x1.date, count(1) as n, x1.prov_id from
(select uid, date, spot, prov_id from temp_ldf0720_smsel3
where spot is not null
group by spot, date, uid, prov_id) x1
group by x1.uid, x1.date, x1.prov_id
) x2
group by x2.prov_id, x2.n;

#



