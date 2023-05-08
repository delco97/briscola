import processing.net.*;

final int PORTA=5792;
int ngioc=2;
Server server;
Tavolo tavolo;
ArrayList<Client> giocatori; 
ArrayList<String> id;
int statoRete=0,statoGioco=0;
boolean iniziato=false;
boolean turno=false;
boolean punti=false;
boolean finecarte=false;
int puntTotale=0;
int[] punti1;
int numTurno=0;

void setup(){
  size(200,200);
  fill(255);
  server=new Server(this,PORTA);
  tavolo=new Tavolo();
  giocatori = new ArrayList<Client>();
  id = new ArrayList<String>();
  punti1=new int[2];
  punti1[0]=0;
  punti1[1]=0;
  println(server.ip());//PER LE ALTRE MACCHINE 10.20.22.216
}

void draw(){
  try{
  background(0);
  switch(statoRete){
    case 0://Collegamento client al server
      Client cl = server.available();
      String letto=null;
      if(cl!=null)
        letto=cl.readString();
      if(cl!=null && !giocatori.contains(cl))//Collegamento dei client
        giocatori.add(cl);
      text("Aspetto i giocatori...",100,100);
      if(letto!=null && letto.equals("D")){
        giocatori.remove(cl);
        server.disconnect(cl);
      }
      text(giocatori.size(),100,200);
      if(giocatori.size()==ngioc)statoRete=1;
    break;
    case 1://Fase di gioco
      Client c = server.available(); 
      if(c!=null && !giocatori.contains(c)){//disconnetto i client in più
          c.write("P");//pieno
          server.disconnect(c);
      }
      if(!iniziato){
        for(int i=0;i<giocatori.size();i++){
          giocatori.get(i).write(new Integer(i).toString());
          id.add(new Integer(i).toString());
        }
        delay(300);
        server.write("I");//inizio
        iniziato=true;
      }
      String[] letto1= new String[2];
      for(int i=0;i<giocatori.size();i++){
        letto1[i]=giocatori.get(i).readString();
        if(letto1[i]!=null && letto1[i].equals("D")){
          server.write("FINE");
          server.stop();
          exit();
        }
      }
      text("GIOCO",100,100);
      
      
      switch(statoGioco){//Gestione delle varie fasi di gioco
        case 0://Distribuzione delle carte. 
          delay(300);//Bisogna distanziare dall'inizio senno legge tutto insieme all'inizio e rimane nello stato di rete 0
          //Quindi se non si mette questo delay si pianta subito all'inizio
          for(int i=0;i<giocatori.size();i++){
            for(int j=0;j<3;j++){//Numero di carte da pelare
              String prova=tavolo.pela().toString();
              giocatori.get(i).write(prova);//Manda la carta
              delay(100);//Distanzio la scrittura delle carte per evitare che il client ne legga più di una insieme
            }
            //Distribuisco la briscola
              Carta br=tavolo.briscola;
              giocatori.get(i).write("B "+br.toString());//Briscola per differenziare
              delay(100);
          }
          turno=false;
          statoGioco=1;// Serve perche sennò continua a dare carte all'infinito
        break;
        case 1://Gioco vero e proprio
          if(!turno){//Fa scrivere solo una volta il coso del turno
            giocatori.get(numTurno).write("T");
            turno=true;
          }
          if(letto1[numTurno]!=null){//Aspetta la decisione della carta dal primo giocatore
            String[] s=letto1[numTurno].split(" ");
            Carta a=new Carta(int(s[0]),int(s[1]),s[2]);
            a.draw();
            tavolo.aggiorna(a);
            turno=false;
            numTurno=(numTurno+1)%ngioc;
            tavolo.invia();//Comunica a tutti i client connessi la carta giocata
          }
          if(tavolo.numCarte()==2)statoGioco=2;
        break;
        case 2://Parte che gestisce la presa del tavolo e chi ha vinto
          delay(800);
          server.write("R");//reset
          delay(100);
          if(tavolo.tavola.get(0).seme==tavolo.tavola.get(1).seme){//Semi uguali
            if(tavolo.tavola.get(1).valfalso>tavolo.tavola.get(0).valfalso){
              //Ha vinto il secondo
              println("Vince id: "+tavolo.tavola.get(1).proprietario);
              if(!punti){//Fa in modo che i punti vengano scritti una sola volta al client
                scriviPunti(1);
                punti=true;
              }
            }
            else{
              //Ha vinto il primo
              println("Vince id: "+tavolo.tavola.get(0).proprietario);
              if(!punti){
                scriviPunti(0);
                punti=true;
              }
            }
            
          }
          else{//Semi diversi
            if(tavolo.tavola.get(0).seme==tavolo.briscola.seme){
              //Ha vinto il primo
              println("Vince id: "+tavolo.tavola.get(0).proprietario);
              if(!punti){
                scriviPunti(0);
                punti=true;
              }
            }
            if(tavolo.tavola.get(1).seme==tavolo.briscola.seme){
              //Ha vinto il secondo
              println("Vince id: "+tavolo.tavola.get(1).proprietario);
              if(!punti){
                scriviPunti(1);
                punti=true;
              }
            }
            if(tavolo.tavola.get(1).seme!=tavolo.briscola.seme){
              //Vince il primo
              println("Vince id: "+tavolo.tavola.get(0).proprietario);
              if(!punti){
                scriviPunti(0);
                punti=true;
              }
            }
          }
          //da le ultime due carte
          println("Carte rimaste nel mazzo : "+ tavolo.carte.size());
          if(tavolo.carte.size()==1 && !finecarte){
            String prova=tavolo.pela().toString();
            giocatori.get((numTurno+1)%(giocatori.size())).write("B "+tavolo.briscola.toString());
            delay(100);
            giocatori.get(numTurno).write("B "+prova.toString());
            delay(100);
            finecarte=true;
          }
          else{// da le carte che non sono le ultime due
            if(!finecarte){
              for(int i=0;i<giocatori.size();i++){
                for(int j=0;j<1;j++){//Numero di carte da pelare
                  String prova=tavolo.pela().toString();
                  giocatori.get(i).write("C "+prova);//Manda la carta
                  delay(300);//Distanzio la scrittura delle carte per evitare che il client ne legga più di una insieme
                }
              }
            }
          }
          tavolo.tavola.clear();
          punti=false;
          statoGioco=1;
          if(puntTotale>=120 && finecarte){
            println("AVANTIGANACOCOBANANA");
            for(int i=0;i<giocatori.size();i++){
              giocatori.get(i).write("A");
              println("scrivo");
           }
            delay(300);
            statoGioco=3;
          }
        break;
        case 3://Fine del gioco
          if(punti1[0]>punti1[1]){
            giocatori.get(0).write("V");
            giocatori.get(1).write("PE");
          }
          if(punti1[0]<punti1[1]){
            giocatori.get(0).write("PE");
            giocatori.get(1).write("V");
          }
          if(punti1[0]==punti1[1]){
            giocatori.get(0).write("S");
            giocatori.get(1).write("S");
          }
          statoGioco=4;//Stato gioco che riceve se si vuole fare un'altra partita
        break;
      }
      
    break;
  }
  }catch(Exception e){}
  
}

void dispose(){
  for(int i=0;i<giocatori.size();i++)
    giocatori.get(i).write("F");//fine
}

/*String mess=giocatori.get(0).readString();
    try{
      text(mess,100,100);
    }catch(Exception e){
      text("Errore",100,100);
    }*/
  
    /*Client c = server.available();
    if(c!=null && c.readString()!=null){//Collegamento dei client
      text(c.readString(),100,100);
      background(100);
    }*/
    
void scriviPunti(int numGiocatore){
  //Prendo l'id di chi vince
  int id_vincitore=int(tavolo.tavola.get(numGiocatore).proprietario);
  int punteggio=0;
  for(int i=0;i<tavolo.tavola.size();i++)//Calcolo i punti totalizzati
    punteggio+=tavolo.tavola.get(i).punteggio;
  for(int i=0;i<giocatori.size();i++){
     if(int(id.get(i))==id_vincitore){
       giocatori.get(i).write("P "+new Integer(punteggio).toString());//Invio i punti totalizzati al vincitore
       punti1[i]+=punteggio;
       delay(100);
       numTurno=i;
       break;
     }
   }
   puntTotale+=punteggio;
   println("Punteggio totale: ",puntTotale);
   
              //Vincitore: "PUNTI <punteggio>"
}

void serverEvent(Server aserver,Client cl){
  cl.write("H");
}
