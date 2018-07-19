#################################################      
###     dato elenco di IDsensore crea file    ###
###     Pluviometri.txt per                   ###
###     importazione in hydstra               ###
###                                           ###
###   MR 18/07/2018                           ### 
#################################################      

library(DBI)
library(RMySQL)
library(RODBC)

file_pluviometri <- '/home/meteo/sviluppo/anagraficaArchivioMeteo/pp_assegnatario.csv'
file_out        <- 'Pluviometri.txt'

#    COLLEGAMENTO AL DB
MySQL(max.con=16,fetch.default.rec=500,force.reload=FALSE)
drv<-dbDriver("MySQL")
conn<-dbConnect(drv,group="Visualizzazione")

#    LETTURA DELLE INFORMAZIONI DA FILE
pluv <- read.csv ( file_pluviometri , header = TRUE , sep=";", as.is = TRUE)

cat("numero_siti ", length(pluv$IDsensore),"\n",file=file_out)

# ricavo nome HYDSTRA da DBmeteo
i<-1
while(i<length(pluv$IDsensore)+1){
query<-paste("select NOMEbreve from A_Sensori,A_Stazioni where A_Stazioni.IDstazione=A_Sensori.IDstazione and IDsensore=",pluv$IDsensore[i],sep="")
print(query)
q_riga <- try(dbGetQuery(conn, query),silent=TRUE)
 if(inherits(q_riga,"try-error")){
  quit(status=1)
 }

# scrivo file di imput per hydstra 
#if(length(q_riga$NOMEbreve)>0 && q_riga$NOMEbreve != NA){
 cat(q_riga$NOMEbreve,  pluv$IDsensore[i], "\n",sep="\t",file=file_out,append=T)
#}else{
# cat("---------------------",  pluv$IDsensore[i], "\n",sep="\t",file=file_out,append=T)
#}  # fine esistenza riga

i <- i + 1
} 

#    DISCONNESSIONE DAL DB
dbDisconnect(conn)
rm(conn)
dbUnloadDriver(drv)

cat ( "PROGRAMMA ESEGUITO CON SUCCESSO alle ", date()," \n" )
