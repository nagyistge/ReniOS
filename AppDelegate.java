package com.bashlord.loginregister;

import android.app.Application;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Parcelable;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;


import com.bashlord.loginregister.cardstream.StreamRetentionFragment;

import org.json.JSONException;
import org.json.JSONObject;

import io.socket.emitter.Emitter;
import io.socket.client.IO;
import io.socket.client.Socket;


import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.Map;


/**
 * Created by JJK on 9/8/15.
 */
public class AppDelegate extends Application {
    Handler handler;
    ProgressDialog progressDialog;
    public Map<String, rendezChatDictionary> theWozMap;// = new HashMap<String, rendezChatDictionary>();
    public ArrayList<Friend> yourFriends = new ArrayList<Friend>();
    public ArrayList<Status> newsFeed = new ArrayList<Status>();
    UserLocalStore userLocalStore;
    User user;
    public NotificationHelper theNotifMap;

    static public Socket mSocket;
    {
        try {
            mSocket = IO.socket(Constants.CHAT_SERVER_URL);

            //mSocket.connect();


        } catch (URISyntaxException e) {
            //throw new RuntimeException(e);
            progressDialog = new ProgressDialog(this);
            progressDialog.setCancelable(true);
            //progressDialog.setTitle("");
            progressDialog.setMessage("Could not complete request.");
        }
    }
    rendezChatDictionary tempWoz;

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d("JJK", "AppDelegate initialized BEGINNING OF ITS LIFECYCLE");
        userLocalStore = new UserLocalStore(this);
        user = userLocalStore.getLoggedInUser();

        //initializing the reciever for emits
        LocalBroadcastManager.getInstance(this).registerReceiver(mMessageReceiver,
                new IntentFilter("startSocket"));
       if(theWozMap == null){
           onStarting();
       }

    }

/*
* called to parse all the data from the get call to the databases into nicely created
* structs (rendez, status, etc) and into arrays and whatnot
* */
    void onStarting(){
        if(user != null){

            Log.d("JJK", "======ON STARTING CALLED=======");
        this.theWozMap = new HashMap<String, rendezChatDictionary>();
        this.theWozMap.put(user.username, new rendezChatDictionary());
        this.theNotifMap = new NotificationHelper();

        ServerRequests serverRequests = new ServerRequests(this);
        serverRequests.onAppStart(user, new onStartCallback() {
            @Override
            public void done(ArrayList chatStatuses) {
                ArrayList<com.bashlord.loginregister.Status> statuses = new ArrayList<Status>();
                ArrayList<RendezStatus> rendezes = new ArrayList<RendezStatus>();
                ArrayList<ChatStatus> chats = new ArrayList<ChatStatus>();
                ArrayList<Friend> friends = new ArrayList<Friend>();

                if ((ArrayList<com.bashlord.loginregister.Status>) chatStatuses.get(0) == null) {
                    statuses = new ArrayList<Status>();
                } else {
                    statuses.addAll((ArrayList<com.bashlord.loginregister.Status>) chatStatuses.get(0));
                }

                if ((ArrayList<RendezStatus>) chatStatuses.get(1) == null) {
                    rendezes = new ArrayList<RendezStatus>();
                } else {
                    rendezes.addAll((ArrayList<RendezStatus>) chatStatuses.get(1));
                    Log.d("JJK", rendezes.toString());
                }

                if ((ArrayList<ChatStatus>) chatStatuses.get(2) == null) {
                    chats = new ArrayList<ChatStatus>();
                } else {
                    chats.addAll((ArrayList<ChatStatus>) chatStatuses.get(2));
                }

                if ((ArrayList<Friend>) chatStatuses.get(3) == null) {
                    friends = new ArrayList<Friend>();
                } else {
                    friends.addAll((ArrayList<Friend>) chatStatuses.get(3));
                }

                newsFeed.clear();
                //Populating the statuses
                Log.d("JJK", "PART 1:->>>PARSING STATUSES" + statuses.size());
                for (int i = 0; i < statuses.size(); i++) {
                    if (!statuses.get(i).username.equals(user.username) && statuses.get(i).username != user.username) {
                        if (isTheFriendInTheWoz(statuses.get(i).username)) {
                            theWozMap.get(statuses.get(i).username).putInStatus(statuses.get(i));
                            newsFeed.add(statuses.get(i));
                            Log.d("JJK", "1111WHERE THE FK ARE THESE STATUSES" + statuses.get(i));
                        } else {
                            theWozMap.put(statuses.get(i).username, new rendezChatDictionary());
                            theWozMap.get(statuses.get(i).username).putInStatus(statuses.get(i));
                            newsFeed.add(statuses.get(i));
                            Log.d("JJK", "2222WHERE THE FK ARE THESE STATUSES" + statuses.get(i));
                        }
                    } else {
                        theWozMap.get(user.username).putInStatus(statuses.get(i));
                    }

                }

                Log.d("JJK", "PART 2:->>>PARSING RENDEZES" + rendezes.size());
                for (int i = 0; i < rendezes.size(); i++) {
                    Log.d("JJK", "BIG PROBLEM HERE I DUNNO WHAT THE EFF THIS IS " + user.username + " " + rendezes.get(i).username + " " + rendezes.get(i).fromuser);
                    if (!rendezes.get(i).username.equals(user.username) && !rendezes.get(i).fromuser.equals(user.username)) {
                        if (isTheFriendInTheWoz(rendezes.get(i).fromuser)) {
                            theWozMap.get(rendezes.get(i).fromuser).allDeesRendez.add(rendezes.get(i));
                            Log.d("JJK", rendezes.get(i).fromuser);

                        } else {
                            theWozMap.put(rendezes.get(i).fromuser, new rendezChatDictionary());
                            theWozMap.get(rendezes.get(i).fromuser).allDeesRendez.add(rendezes.get(i));
                            Log.d("JJK", rendezes.get(i).fromuser + " else");

                        }
                        if(!theNotifMap.isInNotifMap(rendezes.get(i).fromuser)){
                            theNotifMap.addToNotifs( new NotificationNode( rendezes.get(i).fromuser, rendezes.get(i).fromuser));
                        }
                    }

                    if (!rendezes.get(i).username.equals(user.username)) {
                        if (isTheFriendInTheWoz(rendezes.get(i).username)) {
                            theWozMap.get(rendezes.get(i).username).allDeesRendez.add(rendezes.get(i));
                            Log.d("JJK", rendezes.get(i).username);
                        } else {
                            theWozMap.put(rendezes.get(i).username, new rendezChatDictionary());
                            theWozMap.get(rendezes.get(i).username).allDeesRendez.add(rendezes.get(i));
                            Log.d("JJK", rendezes.get(i).username + " USERNAME = USERNAME");
                            //theNotifMap.addToNotifs(new NotificationNode(rendezes.get(i).username, rendezes.get(i).username));
                        }

                        if(!theNotifMap.isInNotifMap(rendezes.get(i).username)){
                            theNotifMap.addToNotifs( new NotificationNode( rendezes.get(i).username, rendezes.get(i).username));
                        }
                    } else if (!rendezes.get(i).fromuser.equals(user.username)) {
                        if (isTheFriendInTheWoz(rendezes.get(i).fromuser)) {
                            theWozMap.get(rendezes.get(i).fromuser).allDeesRendez.add(rendezes.get(i));
                            Log.d("JJK", rendezes.get(i).fromuser);
                        } else {
                            theWozMap.put(rendezes.get(i).fromuser, new rendezChatDictionary());
                            theWozMap.get(rendezes.get(i).fromuser).allDeesRendez.add(rendezes.get(i));
                            Log.d("JJK", rendezes.get(i).fromuser + " FROMUSER = USERNAME");
                            theNotifMap.addToNotifs(new NotificationNode(rendezes.get(i).fromuser, rendezes.get(i).fromuser));
                        }
                        if(!theNotifMap.isInNotifMap(rendezes.get(i).fromuser)){
                            theNotifMap.addToNotifs( new NotificationNode( rendezes.get(i).fromuser, rendezes.get(i).fromuser));
                        }
                    }
                }

                Log.d("JJK", "PART 3:->>>PARSING Chats" + chats.size());
                for (int i = 0; i < chats.size(); i++) {
                    if (!chats.get(i).username.equals(user.username)) {
                        if (isTheFriendInTheWoz(chats.get(i).username)) {
                            theWozMap.get(chats.get(i).username).putInChat(chats.get(i));
                        } else {
                            theWozMap.put(chats.get(i).username, new rendezChatDictionary());
                            theWozMap.get(chats.get(i).username).putInChat(chats.get(i));
                        }
                    } else {
                        if (isTheFriendInTheWoz(chats.get(i).toUser)) {
                            theWozMap.get(chats.get(i).toUser).putInChat(chats.get(i));
                        } else {
                            theWozMap.put(chats.get(i).toUser, new rendezChatDictionary());
                            theWozMap.get(chats.get(i).toUser).putInChat(chats.get(i));
                        }
                    }

                }

                yourFriends = friends;
            }
        });
    }
    }
    //EMIT LISTENERS FOR NEW RENDEZES
    //March 29th 2016
    //remember to change the call (calls from mainactivity.java) to somewhere where the app will open the socket call whenever in use
    //  The issue was that whenever the app was left in a state (such as chattingR.java, then the socket would stop and never start again)
    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String username = intent.getStringExtra("username");
            String title = intent.getStringExtra("showname");
           letsGetThatSocketRollin(username, title);
            Log.d("receiver", "Socket started aaaaaayayaya");
        }
    };

    @Override
    public void onLowMemory() {
        super.onLowMemory();
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
    }


    public void letsGetThatSocketRollin(String username, String showname){

        this.mSocket.on("new message", onNewMessage);
        this.mSocket.on("new rendez", onNewRendez);
        this.mSocket.connect();
        this.mSocket.emit("joinserver", username, showname);

    }

        /*USED TO CHECK THE WOZ MAP TO SEE IF THE FRIEND'S RENDEZES AND CHAT HAS BEEN INITIALLY RETRIEVED
     1. IS CALLED WHEN YOU CLICK ON YOUR FRIENDS NAME IN FRIENDLIST TO SEE THEIR SHIET
     2. OR IF YOU GET A NOTIFICATION FROM A FRIEND.  THAT MEANS YOU SHOULD LOAD THEIR RENDEZES AND CHAT SO YOU CAN APPEND THE NEW
          MESSAGE TO THE END OF THAT LIST SO ITS UPDATED CORRECTLY.
    -CASES-
    1. Use it when you click a friends name to see if their initial chat stuff has been loaded
        -If it has, then just go on to the listview
        -else, load it first with a serverrequest, then move onto viewing

    2. When you get a notification emit from a friend while app is on
        -If true, append the new messege to the end of rendez or chat of the value in <key, value>, which is a rendezChatDictionary

          */

    public Boolean isTheFriendInTheWoz(String friendname){
        if(this.theWozMap.containsKey(friendname)){
            return true;
        }
        else return false;
    }

    /*
    Here we are going to initialize the friends rendez/chat so it can be viewed on the viewadapters.
    -USE CASES-
    1. Whenever you click on a friend on friendlist and theWoz does not have a key for that friend's name, that means it needs to be called
    2. Whenever you get a notification from a friend (a rendez or a chat message)

    NOTE: THIS SHOULD ONLY BE CALLED IF SINCE YOU OPENED THE APP YOU HAVE NOT ATTEMPTED TO VIEW THE FRIEND'S RENDEZES OR CHAT, SHOULD
            BE CALLED ONLY ONCE.

            DEPRECIATED
            METHOD IS KAPUT AND NOT VERY USELESS AFTER FURTHER DEVELOPMENT, DO NOT USE THIS SMUT!!
            */
    public rendezChatDictionary makeFriendsWithWoz(String username, final String friendname) {
        final String friendkey = friendname;
        //rendezChatDictionary temp = new rendezChatDictionary();
        /*
        ServerRequests serverRequests = new ServerRequests(this);
        serverRequests.fetchOnAppStartInBackground(username, friendname, new initTheWozCallback() {
            @Override
            public void done(rendezChatDictionary returned) {
                //theWozMap.put(friendkey, returned);
                tempWoz = returned;
                theWozMap.put(friendname, tempWoz);
            }
        });
        */
        //this.theWozMap.put(friendname, tempWoz);
        return tempWoz;
    }

    public rendezChatDictionary getRendezDictionary(String friendname){
        rendezChatDictionary temp = this.theWozMap.get(friendname);
        return temp;
    }

    public void addRendezToTheWoz(RendezStatus status, String username){
        theWozMap.get(username).allDeesRendez.add(status);

    }

    public void putItInTheWoz(String friendname, rendezChatDictionary WOOOZ){
        this.theWozMap.put(friendname, WOOOZ);

    }

    public void makingFriendlist(Friend friend){
        this.yourFriends.add(friend);
        Log.d("JJK", "muthafuker add the friend goddamit");
    }

    public ArrayList<Friend> getFriends(){
        return this.yourFriends;
    }



    public void emitRendez(int id, String reciever, String title, String detail, String location, String timefor, int type, int response){
        mSocket.emit("send",id, reciever, title, detail, location, new Date().getTime());
    }

    public void emitChat(String reciever, String messege){
        mSocket.emit("send chat", reciever, messege, new Date().getTime());

    }





// SOCKET.IO LISTENERS FOR INCOMING MESSEGES
    public Emitter.Listener onNewMessage = new Emitter.Listener() {
        @Override
        public void call(final Object... args) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    JSONObject data = (JSONObject) args[0];
                    String username;
                    String message;
                    String time;
                    try {
                        //this is a listener, so these following variables make up a message recieved from a friend
                        username = data.getString("username");
                        message = data.getString("message");
                        time = data.getString("time");

                    } catch (JSONException e) {
                        return;
                    }

                    //IF THE MESSAGE HAS BEEN SENT BY A FRIEND WHO YOU HAVE NOT INIT YET
                    if(!isTheFriendInTheWoz(username)){
                        makeFriendsWithWoz(user.username, username);
                    }


                    //theWozMap.
                    rendezChatDictionary temp = theWozMap.get(username);
                    ChatStatus temp1 = new ChatStatus(username,  message, time, user.username);
                    temp.putInChat(temp1);
                    theWozMap.put(username, temp);
                    sendUpdateChatting(temp1);
                    // addMessage(username, message, time);
                }
            });
        }
    };



    public Emitter.Listener onNewRendez = new Emitter.Listener() {
        @Override
        public void call(final Object... args) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    JSONObject data = (JSONObject) args[0];
                    String username;
                    String title;
                    String detail;
                    String location;
                    String time;
                    String showname;
                    int id;
                    int type;
                    int response;
                    try {
                        id = data.getInt("id");
                        username = data.getString("username");
                        showname = data.getString("showname");
                        title = data.getString("title");
                        detail = data.getString("detail");
                        location = data.getString("location");
                        time = data.getString("timefor");
                        type = data.getInt("type");
                        response = data.getInt("response");


                    } catch (JSONException e) {
                        return;
                    }

                    if(!isTheFriendInTheWoz(username)){
                        makeFriendsWithWoz(user.username, username);
                    }

                    rendezChatDictionary temp = theWozMap.get(username);
                    RendezStatus temp1 = new RendezStatus(username, title, detail, location,null, time, type, response, user.username);
                    temp.putInRendez(temp1);
                    theWozMap.put(username, temp);
                    sendUpdateRendezChat(temp1);
                    // addMessage(username, title, detail, location, time);
                }
            });
        }
    };


    private void sendUpdateRendezChat(RendezStatus post){
        Log.d("sender", "Broadcasting message");
        Intent intent = new Intent("updateRendezChat");
        // You can also include some extra data.
        intent.putExtra("id", post.id);
        intent.putExtra("username", post.username);
        intent.putExtra("title", post.title);
        intent.putExtra("details", post.details);
        intent.putExtra("location", post.location);
        intent.putExtra("time", post.timefor);
        intent.putExtra("type", post.type);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }

    private void sendUpdateChatting(ChatStatus post){
        Log.d("sender", "Broadcasting message");
        Intent intent = new Intent("updateChatting");
        // You can also include some extra data.
        intent.putExtra("username", post.username);
        intent.putExtra("details", post.details);
        intent.putExtra("time", post.time);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }

    public void onRendezStart(ArrayList shebang){

    }






    private void runOnUiThread(Runnable runnable) {
        handler.post(runnable);
    }

    private boolean authenticate() {
        if (userLocalStore.getLoggedInUser() == null) {
            Intent intent = new Intent(this, login.class);
            startActivity(intent);
            return false;
        }
        return true;
    }


}
