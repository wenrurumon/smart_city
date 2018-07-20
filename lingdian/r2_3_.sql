
#staymonth中的条目筛选
#fx.date, fx.uid, fx.gender, fx.age, fx.prov_id, fx.ptype, fx.stime, fx.etime, fx.gw, fx.lat, fx.lon, fx.spot

select x2.prov_id, x2.sumdate, count(1) as n from 
(select x.uid, x.prov_id, sum(x.date) as sumdate from 
(select uid, date, prov_id from temp_ldf0720_smsel3 group by uid, date, prov_id) x
group by x.uid, x.prov_id) x2
group by x2.prov_id, x2.sumdate;

#prov, spot, profile count #5483
select x.prov_id, x.gender, x.age, x.spot, x.sumdate, count(1) as n from
(select x1.uid, x1.prov_id, x1.gender, x1.age, x1.spot, sum(x1.date) as sumdate from
(select uid, date, prov_id, gender, age, spot from temp_ldf0720_smsel3 group by date, uid, prov_id, gender, age, spot) x1
group by x1.uid, x1.prov_id, x1.gender, x1.age, x1.spot) x
group by x.prov_id, x.gender, x.age, x.spot, x.sumdate;

#prov, profile count #5486
select x.prov_id, x.gender, x.age, x.sumdate, count(1) as n from
(select x1.uid, x1.prov_id, x1.gender, x1.age, sum(x1.date) as sumdate from
(select uid, date, prov_id, gender, age from temp_ldf0720_smsel3 group by date, uid, prov_id, gender, age) x1
group by x1.uid, x1.prov_id, x1.gender, x1.age) x
group by x.prov_id, x.gender, x.age, x.sumdate;

#prov, profile where spot is true #
select x.prov_id, x.gender, x.age, x.sumdate, count(1) as n from
(select x1.uid, x1.prov_id, x1.gender, x1.age, sum(x1.date) as sumdate from
(select uid, date, prov_id, gender, age from temp_ldf0720_smsel3
where spot is not null
group by date, uid, prov_id, gender, age) x1
group by x1.uid, x1.prov_id, x1.gender, x1.age) x
group by x.prov_id, x.gender, x.age, x.sumdate;

#check r #5489
select x.prov_id, x.r, count(1) as n from
(select x1.uid, x1.prov_id, count(1) as r from
(select uid, spot, prov_id, gender, age from temp_ldf0720_smsel3
where spot is not null
group by spot, uid, prov_id, gender, age) x1
group by x1.uid, x1.prov_id) x
group by x.prov_id, x.r;

#spots #5490
select y.spot, x.r, count(1) as n from 
(select uid, spot from temp_ldf0720_smsel3
where spot is not null
group by uid, spot) y
inner join 
(select x1.uid, x1.prov_id, count(1) as r from
(select uid, spot, prov_id, gender, age from temp_ldf0720_smsel3
where spot is not null
group by spot, uid, prov_id, gender, age) x1
group by x1.uid, x1.prov_id) x
on x.uid = y.uid
group by y.spot, x.r;
