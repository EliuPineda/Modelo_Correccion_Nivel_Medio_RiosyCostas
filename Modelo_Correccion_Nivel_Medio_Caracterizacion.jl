using CSV
using DataFrames
using Plots

println("");println("");println("");println("");println("");println("");println("")
println("###########_Bienvenido_##########")
println("");println("")

#data = CSV.read("C:\\Users\\ELIU\\Desktop\\9_Semestre\\Rios y Costas\\CNM\\DATA.csv")
#data = CSV.read("DATA_parcial.csv")
data = CSV.read("DATA.csv")
#data = CSV.read("resolutionplus.csv")

#Sin correccion
plot(data.t,data.no, title="Modelo Correccion Nivel Medio", label="No Corregido", background_color = RGB(0.2, 0.2, 0.2))
xlabel!("t(s)")
ylabel!("n()")

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

plot!(data.t,[nc_er], label="Ecuacion de la recta")     #Ene "n"corregido

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


nc_ep=Float64[]                                         #Correccion completa con ecuacion de la parabola
for i=1:count
    push!(nc_ep,(data.no[i]-ne_ep[i]))
end

#Convertir a DataFrame para caracterizacion de los diferentes modelos de correccion
datam = DataFrame(n = repeat([0], outer=[count]),
                    t = repeat([0.0], outer=[count]),
                    no = repeat([0.0], outer=[count])
                    )
datar = DataFrame(n = repeat([0], outer=[count]),
                    t = repeat([0.0], outer=[count]),
                    no = repeat([0.0], outer=[count])
                    )
datap = DataFrame(n = repeat([0], outer=[count]),
                    t = repeat([0.0], outer=[count]),
                    no = repeat([0.0], outer=[count])
                    )

for i=1:count
    datam.n[i] = data.n[i]
    datam.t[i] = data.t[i]
    datam.no[i] = nc_ma[i]

    datar.n[i] = data.n[i]
    datar.t[i] = data.t[i]
    datar.no[i] = nc_er[i]

    datap.n[i] = data.n[i]
    datap.t[i] = data.t[i]
    datap.no[i] = nc_ep[i]
end

# CARACTERIZACION FINAL·······························································
function CaracterizacionSenalH(salida)
    #Ordemar H de mayor a menor
    sort!(salida, (order(:H, rev = true)))


    count=size(salida.Index)[1]
    #println(salida)
    #CARACTERZACION H(m)
    numero_de_valores = 0
    suma_datos = 0
    suma_datos_unmedio = 0
    suma_datos_olasignificante = 0
    suma_datos_olaundecimo = 0
    suma_datos_mediacuadratica = 0
    indice_ultimo_olasignificante = 0
    indice_ultimo_olaundecimo = 0
    for i=1:count
        if salida.H[i]>0
            numero_de_valores = numero_de_valores+1
            suma_datos = suma_datos+salida.H[i]
            if i<=(count/2)                                                 #Datos para ola 1/2
                suma_datos_unmedio = suma_datos_unmedio+salida.H[i]
            end
            suma_datos_mediacuadratica = suma_datos_mediacuadratica + salida.H[i]^2  #Para mediacuadrartica
            if i<=(count/3)                                                 #Datos para ola significante
                suma_datos_olasignificante = suma_datos_olasignificante+salida.H[i]
                indice_ultimo_olasignificante = salida.Index[i]+1           #Agarra el ultimo indice y le suma uno
            end
            if i<=(count/10)                                                 #Datos para ola un decimo
                suma_datos_olaundecimo = suma_datos_olaundecimo+salida.H[i]
                indice_ultimo_olaundecimo = salida.Index[i]+1    #Agarra el ultimo indice y le suma uno
            end
        end
    end

    println("-","---------------------------------+++>  Caracterizacion H")
    altura_media = suma_datos/numero_de_valores
    println("Media= ",altura_media)
    altura_media_cuadratica = ((1/numero_de_valores)*suma_datos_mediacuadratica)^(1/2)
    println("Media_Cuadratica= ", altura_media_cuadratica)
    try
        altura_ola_un_medio = (2/numero_de_valores)*suma_datos_unmedio
        println("Ola_Un_Medio= ", altura_ola_un_medio)
    catch
        println("Ola_Un_Medio= ","No_Enough_Data")
    end
    try
        altura_de_ola_significante = (3/numero_de_valores)*(suma_datos_olasignificante+(1/3)*salida.H[indice_ultimo_olasignificante])
        println("Ola_significante= ", altura_de_ola_significante)
    catch
        println("Ola_significante= ","No_Enough_Data")
    end
    try
        altura_de_ola_undecimo = (10/numero_de_valores)*(suma_datos_olaundecimo+(0.4)*salida.H[indice_ultimo_olaundecimo])
        println("Ola_Un_Decimo= ", altura_de_ola_undecimo)
    catch
        println("Ola_Un_Decimo= ","No_Enough_Data")
    end
    println("")
end

function CaracterizacionSenalT(salida)
    sort!(salida, (order(:T, rev = true)))

    count=size(salida.Index)[1]
    #println(salida)
    #CARACTERZACION H(m)
    numero_de_valores = 0
    suma_datos = 0
    suma_datos_unmedio = 0
    suma_datos_olasignificante = 0
    suma_datos_olaundecimo = 0
    suma_datos_mediacuadratica = 0
    indice_ultimo_olasignificante = 0
    indice_ultimo_olaundecimo = 0
    for i=1:count
        if salida.T[i]>0
            numero_de_valores = numero_de_valores+1
            suma_datos = suma_datos+salida.T[i]
            if i<=(count/2)                                                 #Datos para ola 1/2
                suma_datos_unmedio = suma_datos_unmedio+salida.T[i]
            end
            suma_datos_mediacuadratica = suma_datos_mediacuadratica + salida.T[i]^2  #Para mediacuadrartica
            if i<=(count/3)                                                 #Datos para ola significante
                suma_datos_olasignificante = suma_datos_olasignificante+salida.T[i]
                indice_ultimo_olasignificante = salida.Index[i]+1           #Agarra el ultimo indice y le suma uno
            end
            if i<=(count/10)                                                 #Datos para ola un decimo
                suma_datos_olaundecimo = suma_datos_olaundecimo+salida.T[i]
                indice_ultimo_olaundecimo = salida.Index[i]+1    #Agarra el ultimo indice y le suma uno
            end
        end
    end

    println("-","---------------------------------+++>  Caracterizacion T(s)")
    altura_media = suma_datos/numero_de_valores
    println("Media= ",altura_media)
    altura_media_cuadratica = ((1/numero_de_valores)*suma_datos_mediacuadratica)^(1/2)
    println("Media_Cuadratica= ", altura_media_cuadratica)
    try
        altura_ola_un_medio = (2/numero_de_valores)*suma_datos_unmedio
        println("Ola_Un_Medio= ", altura_ola_un_medio)
    catch
        println("Ola_Un_Medio= ","No_Enough_Data")
    end
    try
        altura_de_ola_significante = (3/numero_de_valores)*(suma_datos_olasignificante+(1/3)*salida.T[indice_ultimo_olasignificante])
        println("Ola_significante= ", altura_de_ola_significante)
    catch
        println("Ola_significante= ","No_Enough_Data")
    end
    try
        altura_de_ola_undecimo = (10/numero_de_valores)*(suma_datos_olaundecimo+(0.4)*salida.T[indice_ultimo_olaundecimo])
        println("Ola_Un_Decimo= ", altura_de_ola_undecimo)
    catch
        println("Ola_Un_Decimo= ","No_Enough_Data")
    end
    println("")
end
# CARACTERIZACION FINAL END·······························································


# FUNCION CARACTERZACION
function caracterizacion(data)
    global indice_ultimo_uno
    global maximocresta
    global broker
    global minimovalle
    #Inicializo DataFrame count index n propiedades
    salida = DataFrame((cruceinferior = repeat([0], outer=[count])),
                        (tiempo_cruce = repeat([0.0], outer=[count])),
                       (max_cresta = repeat([0.0], outer=[count])),
                       (n_max = repeat([0.0], outer=[count])),
                       (t_max = repeat([0.0], outer=[count])),
                       (min_valle = repeat([0.0], outer=[count])),
                       (n_min = repeat([0.0], outer=[count])),
                       (t_min = repeat([0.0], outer=[count])),
                       (H = repeat([0.0], outer=[count])),
                       (T = repeat([0.0], outer=[count])),
                        Index = 1:count,
                        )
    #Cruce cruceinferior=1 si inferior_de_un_cruce


    #Cruces ascendentes
    for i=1:count-1                                                                  #recorremos valores desde 1 hasta leng-1
        if data.no[i]<=0 && data.no[i+1]>0                                           #Si el actual es menor o igual a 0 y el siguiente es mayor a cero, nos encontramos en un cruce
            #println("*","Cruce",data.no[i],"___",data.no[i+1])
            if data.no[i]==0
                salida.tiempo_cruce[i] = data.t[i]                                       #Tiempo cuan Tenemmos un cruce puro
                salida.cruceinferior[i] = 1                                          #guardar el indice de los cruces o cruces inferiores ascendentes con un ddto binario
            else                                                                     #Si no hay cruce puro, toca interpolar
                salida.tiempo_cruce[i] = (((data.t[i+1]-data.t[i])/(data.no[i+1]-data.no[i]))*(0-data.no[i]))+data.t[i] #Tiempo de cruce Interpolacion
                salida.cruceinferior[i] = 1                                          #Referir a propiedades
            end
        end
    end


    # "ni" Crestas
    maximocresta = 0
    broker = 0
    for i=1:count
        if salida.cruceinferior[i]==1
            indice_ultimo_uno = data.n[i]                     #Se supone que hay un primer uno que se supone es de finalizacion porque el de finalizacion es de inicio--- Debemos empezar a revisar luego de encontrar el primer 1
            break
        end
    end
    indice_maximocresta = 0
    for z=1:count
        global indice_ultimo_uno
        if salida.cruceinferior[z]==1                         #Itera si hay un inicio
            for i=indice_ultimo_uno:count                     #Itera entre dos puntos cruce inferior 1 - 1 y encuentra el maximo , desde el ultimo uno de finalizacion encontrado
                global maximocresta
                global broker
                global indice_maximocresta
                global indice_ultimo_uno
                if maximocresta<data.no[i]                    #Encuentro el maximo de los valores
                    maximocresta = data.no[i]
                    indice_maximocresta = i                   #Guardo indice maximo cresta para luego ubicar el numero
                    #println(indice_maximocresta)
                end
                if salida.cruceinferior[i]==1                 #Contador para terminar iteracion cuando encuentra el segundo  1
                    broker = 1+broker                         #Encuentra un 1
                    if broker>1                               #Si  el segundo 1 ha sido contado sale del ciclo for, solo hasta este punto podemos tener los valores finales
                        indice_ultimo_uno = data.n[i]
                        #println(indice_maximocresta)
                        #println(data.no[indice_maximocresta])
                        salida.max_cresta[indice_maximocresta]=maximocresta
                        broker = 0                            #Reinicia broker para que en la proxima iteracion no salga de primeras con el dato anterior guardado
                        maximocresta = 0                      #Reinicia el maximo para la proxima iteracion
                        break
                    end
                end
            end
        end
    end


    # "ni" Valles
    minimovalle = 0
    broker = 0
    for i=1:count
        if salida.cruceinferior[i]==1
            indice_ultimo_uno = data.n[i]                     #Se supone que hay un primer uno que se supone es de finalizacion porque el de finalizacion es de inicio
            break
        end
    end
    indice_minimovalle = 0
    for z=1:count
        global indice_ultimo_uno
        if salida.cruceinferior[z]==1                         #Itera si hay un inicio
            for i=indice_ultimo_uno:count                     #Itera entre dos puntos cruce inferior 1 - 1 y encuentra el maximo , desde el ultimo uno de finalizacion encontrado
                global minimovalle
                global broker
                global indice_minimovalle
                global indice_ultimo_uno
                if minimovalle>data.no[i]                    #Encuentro el minimo de los valores
                    if i != indice_ultimo_uno                #No poemos revisar el ultimo valor pasado porque si es menor que los menores siguientes entonces ocurrirá un error porque no encontrará menores
                        minimovalle = data.no[i]
                        indice_minimovalle = i                   #Guardo indice maximo cresta para luego ubicar el numero
                    end
                    #println(indice_minimovalle)
                end
                if salida.cruceinferior[i]==1                 #Contador para terminar iteracion cuando encuentra el segundo  1
                    broker = 1+broker                         #Encuentra un 1
                    if broker>1                               #Si  el segundo 1 ha sido contado sale del ciclo for, solo hasta este punto podemos tener los valores finales
                        indice_ultimo_uno = data.n[i]
                        #if minimovalle >= 0          #Nuevo
                        #    minimovalle = data.no[i]
                        #    indice_minimovalle = i   #Nuevo
                        #end
                        #println(indice_minimovalle)
                        #println(data.no[indice_minimovalle])
                        salida.min_valle[indice_minimovalle]=minimovalle
                        broker = 0                            #Reinicia broker para que en la proxima iteracion no salga de primeras con el dato anterior guardado
                        minimovalle = 0                       #Reinicia el maximo para la proxima iteracion
                        break
                    end
                end
            end
        end
    end

    try
        # Parametros A B C y n_max _CRESTAS
        A = 0
        B = 0
        C = 0
        for i=1:count
            global A,B,C
            if salida.max_cresta[i]>0                               #Condicion para seleccionar los valores.. Esto seleccionna el indice
                A = (1/2)*(data.no[i-1]-2*data.no[i]+data.no[i+1])
                B = (1/2)*(data.no[i+1]-data.no[i-1])
                C = data.no[i]
                #println("*",A,B,C)
                salida.n_max[i] = C-((B^2)/(4*A))
                salida.t_max[i] = data.t[i]-(0.5*B/(2*A))
            end
        end

        # Parametros A B C y n_max _VALLES
        A = 0
        B = 0
        C = 0
        for i=1:count
            global A,B,C
            if salida.min_valle[i]<0                               #Condicion para seleccionar los valores.. Esto seleccionna el indice
                A = (1/2)*(data.no[i-1]-2*data.no[i]+data.no[i+1])
                B = (1/2)*(data.no[i+1]-data.no[i-1])
                C = data.no[i]
                #println("*",A,B,C)
                salida.n_min[i] = C-((B^2)/(4*A))
                salida.t_min[i] = data.t[i]-(0.5*B/(2*A))
            end
        end
    catch
        println("Problema en calculo de parametros A, B, C")
    end

    #Calculo de H
    indice_ultimo = 1
    for i=1:count
        if salida.n_max[i]>0
            for z=indice_ultimo:count
                if salida.n_min[z]<0
                    salida.H[i]=salida.n_max[i]-salida.n_min[z]
                    indice_ultimo = data.n[z]+1                             #Se suma uno al indice para impedir que empieze por el mismo dato y se convierta en un loop
                    break
                end
            end
        end
    end


    #Calculo de T con
    for i=1:count
        if salida.tiempo_cruce[i]>0
            for z=1:count
                if (salida.tiempo_cruce[z]>0) && (salida.tiempo_cruce[z]>salida.tiempo_cruce[i])
                    salida.T[i] = salida.tiempo_cruce[z]-salida.tiempo_cruce[i]
                    break
                end
            end
        end
    end

    #println(salida)
    CaracterizacionSenalH(salida)   #llamar las dos funciones para caracterizacion fnal H y T
    #CaracterizacionSenalT(salida)



    println(salida)
    println("");println("");println("")

end


#CARACTERIZACIONES*******
try
    println("##### CARACTERIZACION DATOS NO CORREGIDOS #####")
    caracterizacion(data)   #DataFrame No corregido
catch
    println("Problem")
end
try
    println("##### CARACTERIZACION DATOS MEDIA ARITMETICA #####")
    caracterizacion(datam)  # Dataframe Media aritmetica
catch
    println("Problem")
end
try
    println("##### CARACTERIZACION DATOS ECUACION DE LA RECTA #####")
    caracterizacion(datar)  #Dataframe ecuacion de la recta
catch
    println("Problem")
end
try
    println("##### CARACTERIZACION DATOS ECUACION DE LA PARABOLA #####")
    caracterizacion(datap)  #Dataframe Ecuacion de la parabola
catch
    println("Problem")
end



plot!(data.t,[nc_ep], label="Ecuacion de la parabola")          #Lo ultimo que presento para que pueda permanecer la grafica
