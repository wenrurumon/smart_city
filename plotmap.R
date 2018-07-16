

color = rainbow(bin, end=0.618)
color = rev(color)
color = colorRampPalette(color)
color = color(100)

value = log(log(d$n+2))
breaks = seq(min(value), max(value), len=bin+1)
breaks[1] = -Inf
col = cut(value, breaks=breaks, label=color)
col = as.character(col)

x = d$lon
y = d$lat
xlim = range(x)
ylim = range(y)
par(mar=rep(0,4)+0.1)
plot(1, type='n', ann=F, axes=F, xlim=xlim, ylim=ylim)
rect(x-0.5, y-0.5, x+0.5, y+0.5, col=col, border=NA)
