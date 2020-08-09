using CSV
using DataFrames
using Plots


data = CSV.read("DATA.csv")

#Sin correccion
plot(data.t,data.no, title="Modelo Correccion Nivel Medio", label="No Corregido", background_color = RGB(0.2, 0.2, 0.2))
xlabel!("t(s)")
ylabel!("n(m)")

#Media aritmetica
Sumno=sum(data.no)
count=size(data.no)[1]
ne_ma=(1/count)*Sumno
nc_ma=Float16[]
for i=1:count
    push!(nc_ma,(data.no[i]-ne_ma))
end
plot!(data.t,[nc_ma], label="Media Aritmetica")

#Ecuacion de una recta
N0i=Float64[]
for i=1:count
    push!(N0i,((data.n[i])^0))
end
N0=sum(N0i)

N1i=Float64[]
for i=1:count
    push!(N1i,((data.n[i])^1))
end
N1=sum(N1i)

N2i=Float64[]
for i=1:count
    push!(N2i,((data.n[i])^2))
end
N2=sum(N2i)

Y0i=Float64[]
for i=1:count
    push!(Y0i,(((data.n[i])^0)*(data.no[i])))
end
Y0=sum(Y0i)

Y1i=Float64[]
for i=1:count
    push!(Y1i,(((data.n[i])^1)*(data.no[i])))
end
Y1=sum(Y1i)

A0=((N2*Y0-N1*Y1)/(N0*N2-(N1^2)))
A1=((N0*Y1-N1*Y0)/(N0*N2-(N1^2)))

ne_er=Float64[]
for i=1:count
    push!(ne_er,(A0+A1*data.n[i]))
end

nc_er=Float64[]
for i=1:count
    push!(nc_er,(data.no[i]-ne_er[i]))
end

plot!(data.t,[nc_er], label="Ecuacion de la recta")

#Ecuacion de una parabola
N3i=Float64[]
for i=1:count
    push!(N3i,((data.n[i])^3))
end
N3=sum(N3i)

N4i=Float64[]
for i=1:count
    push!(N4i,((data.n[i])^4))
end
N4=sum(N4i)

Y2i=Float64[]
for i=1:count
    push!(Y2i,(((data.n[i])^2)*(data.no[i])))
end
Y2=sum(Y2i)

delta=N0*N2*N4+2*N1*N2*N3-(N2^3)-N0*(N3^2)-(N1^2)*N4
B0=(1/delta)*(Y0*(N2*N4-N3^2)+Y1*(N2*N3-N1*N4)+Y2*(N1*N3-N2^2))
B1=(1/delta)*(Y0*(N2*N3-N1*N4)+Y1*(N0*N4-N2^2)+Y2*(N1*N2-N0*N3))
B2=(1/delta)*(Y0*(N1*N3-N2^2)+Y1*(N1*N2-N0*N3)+Y2*(N0*N2-N1^2))

ne_ep=Float64[]
for i=1:count
    push!(ne_ep,(B0+B1*data.n[i]+B2*(data.n[i])^2))
end

nc_ep=Float64[]
for i=1:count
    push!(nc_ep,(data.no[i]-ne_ep[i]))
end

plot!(data.t,[nc_ep], label="Ecuacion de la parabola")
#println(nc_ep)
