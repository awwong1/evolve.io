class CreatureThread extends Thread {
   private Thread t;
   private String threadName;
   private Creature threadOwner;
   double timeStep;
   Boolean userControl;
   
   public CreatureThread(String name, Creature creature, double ts, Boolean uc) {
      threadName = name;
      threadOwner = creature;
      timeStep = ts;
      userControl = uc;
   }
   
   public void run() {
     threadOwner.collide(timeStep);
     threadOwner.metabolize(timeStep);
     threadOwner.useBrain(timeStep, !userControl);
     threadOwner.board.threadsToFinish--;
     if(threadOwner.board.threadsToFinish == 0){
       threadOwner.board.finishIterate(timeStep);
     }
   }
   
   public void start () {
      if (t == null) {
         t = new Thread (this, threadName);
         t.start ();
      }
   }
}

/*void setup(){
    ThreadDemo T1 = new ThreadDemo( "Thread-1");
    T1.start();
    
    ThreadDemo T2 = new ThreadDemo( "Thread-2");
    T2.start();
}*/
