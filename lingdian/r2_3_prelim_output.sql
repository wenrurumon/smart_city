
#prov, profile count #5556
select x.prov_id, x.gender, x.age, x.sumdate, sum(x.gw) as w, count(1) as n from
(select x1.uid, x1.prov_id, x1.gender, x1.age, x1.gw, sum(x1.date) as sumdate from
(select uid, date, prov_id, gender, age, gw from temp_ldf0720_smsel3 group by date, uid, prov_id, gender, age, gw)  x1
group by x1.uid, x1.prov_id, x1.gender, x1.age, x1.gw) x
group by x.prov_id, x.gender, x.age, x.sumdate;

#prov, spot, profile (gender, age, sumdate) count #5554
select x.prov_id, x.gender, x.age, x.spot, x.sumdate, sum(x.gw) as w, count(1) as n from
(select x1.uid, x1.prov_id, x1.gender, x1.age, x1.spot, x1.gw, sum(x1.date) as sumdate from
(select uid, date, prov_id, gender, age, spot, gw from temp_ldf0720_smsel3 group by date, uid, prov_id, gender, age, spot, gw) x1
group by x1.uid, x1.prov_id, x1.gender, x1.age, x1.spot, x1.gw) x
group by x.prov_id, x.gender, x.age, x.spot, x.sumdate;

#check r #5557
select x.prov_id, x.r, sum(x.gw) as w, count(1) as n from
(select x1.uid, x1.prov_id, x1.gw, count(1) as r from
(select uid, spot, prov_id, gender, age, gw from temp_ldf0720_smsel3
where spot is not null
group by spot, uid, prov_id, gender, age, gw) x1
group by x1.uid, x1.prov_id, x1.gw) x
group by x.prov_id, x.r;

#check r #5560
select x.prov_id, x.r, x.countdate, sum(x.gw) as w, count(1) as n from
(select x1.uid, x1.prov_id, x1.gw, count(distinct x1.date) as countdate, count(1) as r from
(select uid, date, spot, prov_id, gender, age, gw from temp_ldf0720_smsel3
where spot is not null
group by spot, date, uid, prov_id, gender, age, gw) x1
group by x1.uid, x1.prov_id, x1.gw) x
group by x.prov_id, x.r, x.countdate;

#spots #5561
select x2.prov_id, x2.nspot, sum(x.gw) as w, count(1) as n2 from 
(
select x1.uid, x1.date, x1.gw, count(1) as nspot, x1.prov_id from
(select uid, date, spot, prov_id, gw from temp_ldf0720_smsel3
where spot is not null
group by spot, date, uid, prov_id, gw) x1
group by x1.uid, x1.date, x1.prov_id, x1.gw
) x2
group by x2.prov_id, x2.n;

#uid, date, stime, cspot
select y3.prov_id, x2.spot1, x2.spot2, x2.spot3, x2.spot4, x2.spot5, x2.spot6, y3.cspot, sum(y3.gw) as w, count(1) as n from 
(
	select y2.prov_id, y2.uid, y2.date, y2.stime, y2.cspot, y2.gw
	from(
		select y1.prov_id, y1.uid, y1.date, min(y1.stime) as stime, count(distinct spot) as cspot
		from (
			select uid, date, spot, prov_id, gw, min(stime) as stime, max(etime) as etime from temp_ldf0720_smsel3
			where spot is not null
			group by uid, date, spot, prov_id, gw
		) y1
		group by y1.uid,y1.date,y1.prov_id, y1.gw
	) y2
	where y2.cspot > 1
	group by y2.prov_id, y2.uid, y2.date, y2.stime, y2.cspot
) y3 left join (
	select x1.uid, x1.date, x1.stime, x1.etime,
	x1.spot as spot1,
	lead(x1.spot,1,0) over (partition by x1.uid, x1.date order by x1.stime) as spot2,
	lead(x1.spot,2,0) over (partition by x1.uid, x1.date order by x1.stime) as spot3,
	lead(x1.spot,3,0) over (partition by x1.uid, x1.date order by x1.stime) as spot4,
	lead(x1.spot,4,0) over (partition by x1.uid, x1.date order by x1.stime) as spot5,
	lead(x1.spot,5,0) over (partition by x1.uid, x1.date order by x1.stime) as spot6
	from (
		select uid, date, spot, prov_id, min(stime) as stime, max(etime) as etime from temp_ldf0720_smsel3
		where 
		spot is not null
		group by uid, date, spot, prov_id
	) x1
) x2
on x2.uid = y3.uid and x2.date = y3.date and x2.stime = y3.stime
group by y3.prov_id, x2.spot1, x2.spot2, x2.spot3, x2.spot4, x2.spot5, x2.spot6, y3.cspot
;
