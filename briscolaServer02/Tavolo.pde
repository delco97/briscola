class Tavolo{
  ArrayList<Carta> carte;  //Carte dele mazzo
  ArrayList<Carta> tavola; //Carte giocate
  Carta briscola;          //Briscola
  
  Tavolo(){//Riempie il mazzo
    carte= new ArrayList<Carta>(40);
    for(int i=1;i<=10;i++){//Valori
      for(int j=0;j<4;j++)//Semi
        carte.add(new Carta(i,j));
    }
    briscola=carte.remove(int(random(carte.size())));
    tavola=new ArrayList<Carta>();
  }
  
  Carta pela(){
    if(carte.size()==1)
      return carte.remove(0);
    return carte.remove(int(random(carte.size())));
  }
  
  void aggiorna(Carta c){
    tavola.add(c);
  }
  
  void invia(){
    for(int i=0;i<tavola.size();i++){
      server.write("TAVOLA "+tavola.get(i).toString());
      delay(100);
    }
  }
  
  int numCarte(){
    return tavola.size();
  }
  
}
