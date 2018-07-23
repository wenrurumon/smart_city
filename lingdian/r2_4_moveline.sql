
#uid, date, stime, cspot

select y3.prov_id, x2.spot1, x2.spot2, x2.spot3, x2.spot4, x2.spot5, x2.spot6, y3.cspot, count(1) as n from 
(
	select y2.prov_id, y2.uid, y2.date, y2.stime, y2.cspot
	from(
		select y1.prov_id, y1.uid, y1.date, min(y1.stime) as stime, count(distinct spot) as cspot
		from (
			select uid, date, spot, prov_id, min(stime) as stime, max(etime) as etime from temp_ldf0720_smsel3
			where spot is not null
			group by uid, date, spot, prov_id
		) y1
		group by y1.uid,y1.date,y1.prov_id
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
