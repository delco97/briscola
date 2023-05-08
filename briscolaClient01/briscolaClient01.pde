import g4p_controls.*;
import processing.net.*;

Client giocatore;
final int PORTA=5792;
int statoRete=-1;
int statoGioco=0;
PImage coperta;
Carta briscola;
ArrayList<Carta> mano;
ArrayList<Carta> tavolo;// Lista di carte che sono sul tavolo in questo momento
int manox=200; // Coordinata x della mano di questo client
int tavolox=300; // Coordinata x del tavolo
boolean turno=false;
boolean finecarte=false;
boolean vinto,perso,pareggio;
int id;
int punteggio=0;
PFont font;

void setup(){
  size(800,600);
  fill(255);
  mano=new ArrayList<Carta>();
  tavolo=new ArrayList<Carta>();
  createGUI();
  textAlign(CENTER,CENTER);
  font=loadFont("CooperBlack-48.vlw");
  textFont(font);
  textSize(30);
}

void draw(){
  try{
  background(0);
  //text(punteggio,400,400);
  //text("id "+id,450,400);
  switch(statoRete){
    case -1://Fa inserire lip del server al quale connettersi
      text("INSERISCI L'IP DEL SERVER",width/2,30);
    break;
    case 0://Sta aspettando che si colleghino gli altri client
      text("ATTENDI ALTRI GIOCATORI",width/2,30);
      if(giocatore.available()>0){
        String letto=giocatore.readString();
        println(letto);
        if(letto.equals("I"))//inizio
          statoRete=1;
        if(letto.equals("P"))//pieno
          statoRete=2;
        if(letto.equals("0"))
          id=0;
        if(letto.equals("1"))
          id=1;
      }
    break;
    case 1://Gioco
      String letto1=giocatore.readString();
      String[] parts={"Z"};
      if(letto1!=null && letto1.equals("A"))
            statoGioco=3;
      if(letto1!=null){
        println(letto1);
        parts=letto1.split(" ");//serve per controllare che la carta ricevuta sia quella di briscola o no
      }
      if(letto1!=null && letto1.equals("F"))
        exit();
      //text("GIOCO",width/2,30);
      
      switch(statoGioco){
        case 0://Ricezione delle carte.
          if(letto1!=null){
            if(!parts[0].equals("B")){//briscola
              mano.add(new Carta(letto1,manox,height-100));
              manox+=100;
            }
            else{
              println(letto1);
              briscola=new Carta(parts[1]+" "+parts[2]+" "+parts[3],0,0);
            }
          }
          if(mano.size()==3 && briscola!=null){statoGioco=1;manox=200;}//Va al prossimo stato
        break;
        case 1://Gioco vero e proprio
          
          if(tavolo.size()==0)
            tavolox=200;
          String[] s1={"Z"};
          boolean contiene=false;
          if(letto1!=null)
            s1=letto1.split(" ");
          if(s1[0].equals("TAVOLA")){
            Carta appoggio=new Carta(s1[1]+" "+s1[2]+" "+s1[3],tavolox,200);
            for(int i=0;i<tavolo.size();i++){
              if(appoggio.equals(tavolo.get(i))){
                contiene=true;
                break;
              }
            }
            if(!contiene){
              tavolo.add(appoggio);
              tavolox+=100;
            }
          }
          for(int i=0;i<mano.size();i++){//Disegno le carte della mia mano
            mano.get(i).draw();
          }
          for(int i=0;i<tavolo.size();i++){//Disegno le carte sulla tavola
            tavolo.get(i).draw();
          }
          if(!finecarte){
            pushMatrix();//Disegno la briscola
              translate(100,100);
              rotate(PI/2);
              briscola.draw();
            popMatrix();
          }
          if(letto1!=null && letto1.equals("T"))turno=true;
          if(turno){
            //Puo lanciare carte
            text("E' IL TUO TURNO",width/2,30);
            for(int i=0;i<mano.size();i++){
              if(mano.get(i).isClicked()){
                Carta lanciata=mano.remove(i);
                println(lanciata.toString());
                giocatore.write(lanciata.toString()+" "+new Integer(id).toString());
                turno=false;
                break;
              }
            }
          }
          else{
            //Aspetta che gli venga riassegnato il turno
            text("ATTENDI SCELTA AVVERSARIA",width/2,30);
          }
          if(s1[0].equals("C")){
            riordinaDispCarte();
            mano.add(new Carta(s1[1]+" "+s1[2]+" "+s1[3],mano.get(mano.size()-1).x+100,height-100));
          }
          if(s1[0].equals("B")){
            riordinaDispCarte();
            mano.add(new Carta(s1[1]+" "+s1[2]+" "+s1[3],mano.get(mano.size()-1).x+100,height-100));
            finecarte=true;
          }
          if(letto1!=null && letto1.equals("R"))//reset
            tavolo.clear();
          if(s1[0].equals("P"))
            punteggio+=int(s1[1]);
          
        break;
        case 3:// Schermata finale
          if(letto1!=null){
            println("letto2 :"+letto1);
            if(letto1.equals("V"))
              vinto=true;
            if(letto1.equals("PE"))
                perso=true;
            if(letto1.equals("S"))
              pareggio=true;
          }
          if(vinto)
            text("HAI VINTO!!!",width/2,height/2);
          if(perso)
            text("HAI PERSO",width/2,height/2);
          if(pareggio){
            text("PAREGGIO!!!",width/2,height/2);
          }
        break;
      }
      
    break;
    case 2://Server pieno o sta gia ospitando una partita
      text("SERVER PIENO",width/2,30);
    break;
    
  }
  }catch(Exception e){}
  
  /*giocatore.write(new Integer(i).toString());
  i++;
  text(i,100,100);*/
}

void dispose(){ // Codice che viene eseguito quando la finestra si chiude
  if(giocatore!=null)
    giocatore.write("D");//disconnetto
}

void riordinaDispCarte(){
  for(int i=0;i<mano.size();i++){
    mano.get(i).setX(manox);
    manox+=100;
  }
  manox=200;
}
