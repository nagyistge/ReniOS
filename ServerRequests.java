package com.bashlord.loginregister;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.ContentValues;
import android.content.Context;
import android.os.AsyncTask;

import android.util.Log;
import android.util.Pair;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.simple.parser.JSONParser;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.lang.reflect.Array;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Objects;


/**
 * Created by JJK on 7/13/15.
 */
public class ServerRequests extends Activity{
    ProgressDialog progressDialog;
    public static final int CONNECTION_TIMEOUT = 1000 * 15;
    public static final String SERVER_ADDRESS = "http://www.jjkbashlord.com/";
    public static final String TAG = "THE-TAG";
    UserLocalStore userLocalStore;

    public ServerRequests(Context context) {
        progressDialog = new ProgressDialog(context);
        progressDialog.setCancelable(false);
        progressDialog.setTitle("Processing");
        progressDialog.setMessage("Please wait....");

    }

    public void storeUserDataInBackground(User user, GetUserCallback userCallback) {
        progressDialog.show();
        new StoreUserDataAsyncTask(user, userCallback).execute();
    }

    public void fetchUserDataInBackground(User user, OnLoginInfo callback) {
        progressDialog.show();
        new fetchUserDataAsyncTask(user, callback).execute();

    }

    public void storeStatusDataInBackground(Status status, GetStatusCallback callback){
        progressDialog.show();
        new StoreStatusData(status, callback).execute();
    }

    public void fetchStatusDataInBackground(User user, GetStatusArrayCallback callback){
        //progressDialog.show();
        new fetchStatusDataAsyncTask(user, callback).execute();
    }

    public void deleteStatusDataInBackground(Status status, GetStatusCallback callback){
        progressDialog.show();
        new deleteStatusDataAsyncTask(status, callback).execute();
    }


    public void storeUserEmailBackground(User user, GetUserCallback userCallback, int flag) {
        progressDialog.show();
        new StoreUserEmailAsyncTask(user, userCallback, flag).execute();
    }


    //~~~~~~~THIS SYNCS CONTACTS AND EMAILS
    public void fetchFriendListInBackground(ArrayList<User> friendlist, String username, GetFriendListCallback callback, int flag){
        progressDialog.show();
        Log.d("JJK", "BEGINNING OF FETCH STATEMENT");
        new fetchFriendListAsyncTask(friendlist, username, callback).execute();
    }


    //~~THIS IS FOR FETCHING FRIENDS DEPENDING ON THE FLAG, SUCH AS INVITE TO APP, ADD FRIEND, CURRENT FRIENDS
    public void fetchFriendsInBackground(User user, GetInviteFriendListCallback callback, int flag){
        //progressDialog.show();
        new fetchFriendsAsyncTask(user, callback, flag).execute();
    }

    public void fetchFriendsNotifInBackground(User user, GetInviteFriendListCallback callback){
        //progressDialog.show();
        new fetchFriendsNotifAsyncTask(user, callback).execute();
    }



    public void addFriendInBackground(User user, Friend friend, GetUserCallback callback, int flag){
        //progressDialog.show();
        new addFriendAsyncTask(user, friend, callback, flag).execute();
    }


    public void sendToFriendsInBackground(User user, ArrayList<Friend> friendlist, RendezStatus sendStatus, GetUserCallback callback){
        //progressDialog.show();
        new sendToFriendsAsyncTask(user, friendlist,sendStatus,  callback).execute();
    }

    public void sendChatToFriendsInBackground(User user, ArrayList<Friend> friendlist, ChatStatus sendStatus, GetUserCallback callback){
        //progressDialog.show();
        new sendChatToFriendsAsyncTask(user, friendlist,sendStatus,  callback).execute();
    }


    public void fetchRendezChatDataInBackground(User user, Friend friend, GetChatStatusCallback callback){
        //progressDialog.show();
        new fetchRendezChatDataAsyncTask(user,friend,  callback).execute();
    }


    public void fetchFriendStatusInBackground(User user, GetStatusArrayCallback callback){
        new fetchFriendStatusDataAsyncTask(user, callback).execute();
    }

    public void onAppStart(User user, onStartCallback callback){
        new fetchOnStart(user.username, callback).execute();
    }


    public void onStatusResponse(fromuser user,int status_id, int flag, GetStatusCallback callback){
        new onStatusResponseInBackground(user, status_id,flag,  callback).execute();
    }

    public void onCreateGroup(String user, String status_id,ArrayList<Friend> friendlist, GetUserCallback callback){
        new createGroupAsyncTask(user, status_id,friendlist,  callback).execute();
    }

    public void postLoc(String username, String friendname, String loc, GetUserCallback callback){
        new postLocAsync(username, friendname, loc,  callback).execute();
    }

    public class postLocAsync extends AsyncTask<Void, Void, Void> {
        String username, friendname, loc;
        GetUserCallback callback;


        public postLocAsync(String username, String friendname, String loc,GetUserCallback callback) {
           this.username = username;
            this.friendname = friendname;
            this.loc = loc;
            this.callback = callback;
        }

        @Override
        protected Void doInBackground(Void... params) {
            ArrayList<Friend> inviteFriendlist = new ArrayList<>();

            //String POST_PARAMS = "param1" + user.username + "&param2=" + user.password;
            //Log.d("JJK", POST_PARAMS);
            String php = "onLocationUpdate.php";

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {

                Log.d("JJK", "CONNECTION ATTEMPT");

                obj = new URL(SERVER_ADDRESS+php);
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = "";


                jsonParam += URLEncoder.encode("username", "UTF-8")
                        + "=" + URLEncoder.encode(username, "UTF-8");

                jsonParam += "&" + URLEncoder.encode("friendname", "UTF-8")
                        + "=" + URLEncoder.encode(friendname, "UTF-8");
                jsonParam += "&" + URLEncoder.encode("location", "UTF-8")
                        + "=" + URLEncoder.encode(loc, "UTF-8");



                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", jsonParam);
                outputstream.write(jsonParam.getBytes(charset));
                outputstream.flush();
                outputstream.close();

                Log.d("JJK", "BEFORE RESPONSE CODE");
                int responseCode = con.getResponseCode();
                Log.d("JJK", "POST Response Code :: " + responseCode);
                //int responseCode = con.getResponseCode();
                //Log.d("JJK", "POST Response Code :: " + responseCode);
                //Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());

                String jsonReply;
                byte[] bytes = new byte[1];

                outputstream.close();

            }
            catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
            // Log.d("JJK", "RETURNED AND PASSWORD: "+returneduser.username + " : " + returneduser.password);
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            progressDialog.dismiss();
            callback.done(null);


            super.onPostExecute(aVoid);
        }
    }
    //on create a new group server request

    public class createGroupAsyncTask extends AsyncTask<Void, Void, Void> {
        String groupname;
        String groupdetail;
        ArrayList<Friend> friendlist;
        GetUserCallback callback;


        public createGroupAsyncTask(String groupname, String groupdetail, ArrayList<Friend> friendlist,GetUserCallback callback) {
            this.groupname = groupname;
            this.groupdetail = groupdetail;
            this.callback = callback;
            this.friendlist = friendlist;
        }

        @Override
        protected Void doInBackground(Void... params) {
            ArrayList<Friend> inviteFriendlist = new ArrayList<>();

            //String POST_PARAMS = "param1" + user.username + "&param2=" + user.password;
            //Log.d("JJK", POST_PARAMS);
            String php = "onAndroidGroupCreation.php";

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {

                Log.d("JJK", "CONNECTION ATTEMPT");

                obj = new URL(SERVER_ADDRESS+php);
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;



                JSONArray JSONsender = new JSONArray();
                JSONArray JSONfriendlist = new JSONArray();

                JSONObject jsonuser = new JSONObject();
                jsonuser.put("groupname", groupname);
                jsonuser.put("groupdetail", groupdetail);
                JSONsender.put(jsonuser);


                for(int i = 0; i < friendlist.size(); i++) {
                    JSONObject friend = new JSONObject();
                    try {
                        friend.put("username", friendlist.get(i).username);
                        friend.put("showname", friendlist.get(i).friendname);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    JSONfriendlist.put(friend);
                }
                JSONObject friendlistJSON = new JSONObject();
                friendlistJSON.put("array", JSONfriendlist);

                JSONsender.put(friendlistJSON);

                OutputStream out = new BufferedOutputStream(con.getOutputStream());
                BufferedWriter os = new BufferedWriter(new OutputStreamWriter(out, "UTF-8"));

                jsonParam = URLEncoder.encode("json", "UTF-8")
                        + "=" + URLEncoder.encode(JSONsender.toString(), "UTF-8");



                //POST STUFF

                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", JSONsender.toString());
                Log.d("JJK", friendlistJSON.toString());
                Log.d("JJK", jsonuser.toString());


                os.write(jsonParam);
                os.flush();

                Log.d("JJK", "BEFORE RESPONSE CODE");
                int responseCode = con.getResponseCode();
                Log.d("JJK", "POST Response Code :: " + responseCode);
                //int responseCode = con.getResponseCode();
                //Log.d("JJK", "POST Response Code :: " + responseCode);
                //Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());

                String jsonReply;
                byte[] bytes = new byte[1];

                outputstream.close();

            }
            catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
            // Log.d("JJK", "RETURNED AND PASSWORD: "+returneduser.username + " : " + returneduser.password);
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            progressDialog.dismiss();
            callback.done(null);


            super.onPostExecute(aVoid);
        }
    }


    public class onStatusResponseInBackground extends AsyncTask<Void, Void, Void> {
        fromuser user;
        GetStatusCallback callback;
        int status_id;
        int flag;

        public onStatusResponseInBackground(fromuser user, int status_id, int flag, GetStatusCallback callback){
            this.user = user;
            this.callback = callback;
            this.status_id = status_id;
            this.flag = flag;
        }

        @Override
        protected Void doInBackground(Void... params) {
            String POST_PARAMS = "id=" +Integer.toString(status_id)+ "&username=" + user.user + "&response=" + user.response;

            Log.d("JJK", POST_PARAMS);

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {
                //just cause i know im probably gunna forget what the heck the flag does...
                //flag = 0 it is doing a status response update, thus the fromuser is from A FRIEND OF YOURS.
                //          This means that although it is your username that is being passed in as well as your status id,
                //              that is only because of the way that statusResponse table is set up in sql

                //flag = 1 this is you responding to a private rendezStatus from a friend.  you update your response and
                            //pass in the parameters of your name once again with your response
                Log.d("JJK", "CONNECTION ATTEMPT");
                obj = new URL(SERVER_ADDRESS+"updateStatusResponse.php");

                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;
                //jsonParam.put("username", userparam);
                // jsonParam.put("password", passwordparam);


                jsonParam = URLEncoder.encode("id", "UTF-8")
                        + "=" + Integer.toString(status_id);

                    jsonParam += "&" + URLEncoder.encode("username", "UTF-8")
                            + "=" + URLEncoder.encode(user.user, "UTF-8");

                jsonParam += "&" + URLEncoder.encode("response", "UTF-8")
                        + "=" + Integer.toString(user.response);
                jsonParam += "&" + URLEncoder.encode("flag", "UTF-8")
                        + "=" + Integer.toString(flag);

                //POST STUFF
                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", jsonParam);
                outputstream.write(jsonParam.getBytes(charset));
                outputstream.flush();
                outputstream.close();
                Log.d("JJK", "BEFORE RESPONSE CODE");
                String jsonReply;
                byte[] bytes = new byte[1];
                if(con.getResponseCode()==201 || con.getResponseCode()==200)
                {



                }
                outputstream.close();



            }

            catch (MalformedURLException muex) {
                // TODO Auto-generated catch block
                muex.printStackTrace();
            } catch (IOException ioex){
                ioex.printStackTrace();
            }
            catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
            // Log.d("JJK", "RETURNED AND PASSWORD: "+returneduser.username + " : " + returneduser.password);
            //return returnedStatus;
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {

            callback.done(null);


            super.onPostExecute(aVoid);
        }

    }


    public class fetchOnStart extends AsyncTask<Void, Void, ArrayList> {
        String user;
        onStartCallback callback;

        public fetchOnStart(String user, onStartCallback callback) {
            this.user = user;
            this.callback = callback;
        }

        @Override
        protected ArrayList doInBackground(Void... params) {
            ArrayList<com.bashlord.loginregister.Status> returnedStatus = new ArrayList<com.bashlord.loginregister.Status>();
            ArrayList<ChatStatus> returnedChat = new ArrayList<>();
            String username = null;
            String title = null;
            String detail = null;
            String location = null;
            //String POST_PARAMS = "param1" + user.username + "&param2=" + user.password;
            String userparam = user;
            // Log.d("JJK", POST_PARAMS);

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            ArrayList<com.bashlord.loginregister.Status> statuses = new ArrayList<>();
            ArrayList<RendezStatus> rendezes = new ArrayList<>();
            ArrayList<ChatStatus> chats = new ArrayList<>();
            ArrayList<Friend> friends = new ArrayList<>();
            try {
                Log.d("JJK", "CONNECTION ATTEMPT");
                obj = new URL(SERVER_ADDRESS + "onLoginAndroid.php");
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;
                //jsonParam.put("username", userparam);
                // jsonParam.put("password", passwordparam);


                jsonParam = URLEncoder.encode("username", "UTF-8")
                        + "=" + URLEncoder.encode(userparam, "UTF-8");

                //POST STUFF

                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", jsonParam);

                outputstream.write(jsonParam.getBytes(charset));

                //outputstream.write(jsonParam.toString());
                outputstream.flush();
                outputstream.close();

                Log.d("JJK", "BEFORE RESPONSE CODE");
                //int responseCode = con.getResponseCode();
                //Log.d("JJK", "POST Response Code :: " + responseCode);
                //Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());

                String jsonReply;
                byte[] bytes = new byte[1];
                if (con.getResponseCode() == 201 || con.getResponseCode() == 200) {
                    BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
                    jsonReply = in.readLine();


                    //jsonReply = response.toString();
                    Log.d("JJK", "JSONREPLY SHOULD BE RIGHT AFTER THIS???");
                    Log.d("JJK", jsonReply);
                    Log.d("JJK", Integer.toString(jsonReply.length()));
                    JSONObject jsonD = new JSONObject(jsonReply);
                    String time;
                    int type;
                    String timeset;
                    String timefor;
                    int visable;
                    ArrayList<com.bashlord.loginregister.Status> statusList;
                    String fromuser;
                    String touser;
                    String friendname;




                    JSONArray jsonStatus = jsonD.getJSONArray("Status");
                    JSONArray jsonRendez = jsonD.getJSONArray("RendezStatus");
                    JSONArray jsonChat = jsonD.getJSONArray("RendezChat");

                    JSONArray jsonFriends = jsonD.getJSONArray("Friends");


                    /*
                        Lets get this all straight cause everything was too hectic befiore....
                        jsonStatus is the array of STATUSES yours and friends that are public
                            -Statuses have all the same parameters except for fromuser which may either be a response form
                             you to a friends status or it is your own status so it has an array of fromuser responses from friends
                            -the visable flag is only needed for your own statuses; if it is a friends, it is obviously visable and thus
                            does not need to be set into the constructor.

                        jsonRendez is the array of all privately sent rendezes from you to a friend, all of these are similar
                        Jsonchat is the same, but its a chat.

                    */

                    String param1;//username
                    String param2;//title
                    String param3;//details
                    String param4;//location
                    String param5;//timeest
                    String param6;//timefor
                    int param7;//type
                    int param8;//visable
                    int param9;//a response from you to a friend
                    //String param10;
                    int id;
                    JSONArray fuParam;//the responses you get from a status
                    String fromuserString;//the name of just you responding.

                    String fromuser1;
                    int response1;


                    for (int i = 0; i < jsonStatus.length(); i++) {
                        id = jsonStatus.getJSONObject(i).getInt("id");
                        param1 = jsonStatus.getJSONObject(i).getString("username");
                        param2 = jsonStatus.getJSONObject(i).getString("title");
                        param3 = jsonStatus.getJSONObject(i).getString("details");
                        param4 = jsonStatus.getJSONObject(i).getString("location");
                        param5 = jsonStatus.getJSONObject(i).getString("timeset");
                        param6 = jsonStatus.getJSONObject(i).getString("timefor");
                        param7 = jsonStatus.getJSONObject(i).getInt("type");
                        param8 = jsonStatus.getJSONObject(i).getInt("visable");
                        //here is where we should be doing the differentiation between a status by you and by a friend
                        ArrayList<fromuser> fromuserr = new ArrayList<>();
                        if(param1.equals(user)){
                            fuParam = jsonStatus.getJSONObject(i).getJSONArray("fromuser");
                            for(int j = 0; j < fuParam.length(); j++){
                                fromuser1 = fuParam.getJSONObject(j).getString("friendname");
                                response1 = fuParam.getJSONObject(j).getInt("response");
                                fromuserr.add(new fromuser(fromuser1, response1));
                                Log.d("JJK", "FROM USERSSSSSS " + fromuser1 + " "  + response1);
                            }
                            Log.d("JJK", "FROMUSER ARRAY " + fromuserr.toString());
                            com.bashlord.loginregister.Status status = new com.bashlord.loginregister.Status(id, param1, param2, param3, param4, param5, param6,
                                    param7, fromuserr, param8);
                            statuses.add(status);

                        }else{

                                param9 = jsonStatus.getJSONObject(i).getInt("response");

                            fromuserString = jsonStatus.getJSONObject(i).getString("fromuser");
                            com.bashlord.loginregister.Status status = new com.bashlord.loginregister.Status(id, param1, param2, param3, param4, param5, param6,
                                    param7, param9, user);
                            statuses.add(status);
                        }

                    }

                    for (int i = 0; i < jsonRendez.length(); i++) {
                        id = jsonRendez.getJSONObject(i).getInt("id");
                        param1 = jsonRendez.getJSONObject(i).getString("username");
                        param2 = jsonRendez.getJSONObject(i).getString("title");
                        param3 = jsonRendez.getJSONObject(i).getString("detail");
                        param4 = jsonRendez.getJSONObject(i).getString("location");
                        param5 = jsonRendez.getJSONObject(i).getString("timeset");
                        param6 = jsonRendez.getJSONObject(i).getString("timefor");
                        param7 = jsonRendez.getJSONObject(i).getInt("type");
                        param8 = jsonRendez.getJSONObject(i).getInt("response");
                        fromuserString =jsonRendez.getJSONObject(i).getString("fromuser");

                        RendezStatus rs = new RendezStatus(id, param1, param2, param3, param4, param5, param6, param7, param8, fromuserString);
                        rendezes.add(rs);


                    }

                    for (int i = 0; i < jsonChat.length(); i++) {
                        param1 = jsonChat.getJSONObject(i).getString("username");
                        param2 = jsonChat.getJSONObject(i).getString("friendname");
                        param3 = jsonChat.getJSONObject(i).getString("chat");
                        param4 = jsonChat.getJSONObject(i).getString("time");
                        ChatStatus cs = new ChatStatus(param1, param2, param3, param4);
                        chats.add(cs);
                    }

                    for (int i = 0; i < jsonFriends.length(); i++) {
                        param1 = jsonChat.getJSONObject(i).getString("username");
                        param2 = jsonChat.getJSONObject(i).getString("friendname");
                        param4 = jsonChat.getJSONObject(i).getString("time");
                        param5 = jsonChat.getJSONObject(i).getString("loctime");
                        param6 = jsonChat.getJSONObject(i).getString("location");
                        DateFormat formatter ;
                        Date date ;
                        formatter = new SimpleDateFormat("dd-MM-yyyy hh:mm:ss");
                        date = (Date)formatter.parse(param5);
                        java.sql.Timestamp t = new Timestamp(date.getTime());

                        Friend f = new Friend(param1, param2, param4, t, param6);
                        friends.add(f);
                    }



                    //returneduser = new User(username, password);
                    in.close();
                }
                outputstream.close();


            } catch (MalformedURLException muex) {
                // TODO Auto-generated catch block
                muex.printStackTrace();
            } catch (IOException ioex) {
                ioex.printStackTrace();
            } catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
            // Log.d("JJK", "RETURNED AND PASSWORD: "+returneduser.username + " : " + returneduser.password);
            /*rendezChatDictionary returnedDic = new rendezChatDictionary();
            returnedDic.initRendez(returnedStatus);
            returnedDic.initChat(returnedChat);
            return returnedDic;*/
            ArrayList returned = new ArrayList();
            returned.add(0,statuses);
            returned.add(1,rendezes);
            returned.add(2,chats);
            returned.add(3,friends);

            return returned;
        }
        protected void onPostExecute(ArrayList returned) {
            super.onPostExecute(returned);
            //progressDialog.dismiss();
            callback.done(returned);

        }
    }






        //WEOFNWEKLMWEFNEOILVKWNEVWLKNVWELKFNWECWEWE THIS RETURNS THE CHAT.  NOT SURE IF I WILL USE THIS OR THE SOCKET... OH THE HUMANITY
    public class fetchRendezChatDataAsyncTask extends AsyncTask<Void, Void, ArrayList<ChatStatus>> {
        User user;
        GetChatStatusCallback callback;
        Friend friend;

        public fetchRendezChatDataAsyncTask(User user,Friend friend, GetChatStatusCallback callback) {
            this.user = user;
            this.callback = callback;
            this.friend = friend;
        }

        @Override
        protected ArrayList<ChatStatus> doInBackground(Void... params) {
            ArrayList<ChatStatus> returnedStatus = new ArrayList<ChatStatus>();
            String username = null;
            String title = null;
            String detail = null;
            String location = null;
            String POST_PARAMS = "param1" + user.username + "&param2=" + user.password;
            String userparam = user.username;
            String friendparam = friend.username;
            Log.d("JJK", POST_PARAMS);

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {
                Log.d("JJK", "CONNECTION ATTEMPT");
                obj = new URL(SERVER_ADDRESS+"fetchRendevousChat.php");
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;
                //jsonParam.put("username", userparam);
                // jsonParam.put("password", passwordparam);


                jsonParam = URLEncoder.encode("username", "UTF-8")
                        + "=" + URLEncoder.encode(userparam, "UTF-8");
                jsonParam += "&" + URLEncoder.encode("friend", "UTF-8")
                        + "=" + URLEncoder.encode(friendparam, "UTF-8");

                //POST STUFF

                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", jsonParam);

                outputstream.write(jsonParam.getBytes(charset));

                //outputstream.write(jsonParam.toString());
                outputstream.flush();
                outputstream.close();

                Log.d("JJK", "BEFORE RESPONSE CODE");
                //int responseCode = con.getResponseCode();
                //Log.d("JJK", "POST Response Code :: " + responseCode);
                //Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());

                String jsonReply;
                byte[] bytes = new byte[1];
                if(con.getResponseCode()==201 || con.getResponseCode()==200)
                {
                    BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
                    jsonReply = in.readLine();


                    //jsonReply = response.toString();
                    Log.d("JJK", jsonReply);
                    JSONArray jsonD = new JSONArray(jsonReply);
                    //JSONObject user = jsonD.getJSONObject(0);
                    //JSONObject pass = jsonD.getJSONObject(1);

                    //jsonReply = convertStreamToString(response);
                    //Log.d("JJK", "INPUT REPLY: "+jsonReply);
                    //JSONArray jarray = new JSONArray(jsonReply);
                    // username = jarray.getString(0);
                    // password = jarray.getString(1);
                    String friendname;
                    for(int i = 0; i < jsonD.length(); i++) {
                        String time;
                        username = jsonD.getJSONObject(i).getString("username");
                        title = jsonD.getJSONObject(i).getString("title");
                        detail = jsonD.getJSONObject(i).getString("detail");
                        location = jsonD.getJSONObject(i).getString("location");
                        time = jsonD.getJSONObject(i).getString("timestamp");
                        friendname = jsonD.getJSONObject(i).getString("friendname");
                        ChatStatus statusQuery = new ChatStatus(username, friendname, detail, time);
                        returnedStatus.add(statusQuery);
                        Log.d("JJK", "FIRST AND LAST: " + username + " : " + title + " : " + detail + " : " + location+ "\n");
                    }

                    //returneduser = new User(username, password);
                    in.close();
                }
                outputstream.close();



            }

            catch (MalformedURLException muex) {
                // TODO Auto-generated catch block
                muex.printStackTrace();
            } catch (IOException ioex){
                ioex.printStackTrace();
            }
            catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
            // Log.d("JJK", "RETURNED AND PASSWORD: "+returneduser.username + " : " + returneduser.password);
            return returnedStatus;
        }

        protected void onPostExecute(ArrayList<ChatStatus> returnedStatus) {
            super.onPostExecute(returnedStatus);
            //progressDialog.dismiss();
            callback.done(returnedStatus);

        }
    }








    public class sendToFriendsAsyncTask extends AsyncTask<Void, Void, Void> {
        User user;
        ArrayList<Friend> friendlist;
        GetUserCallback callback;
        RendezStatus sendStatus;

        public sendToFriendsAsyncTask(User user, ArrayList<Friend> friendlist,RendezStatus sendStatus, GetUserCallback callback) {
            this.user = user;
            this.callback = callback;
            this.friendlist = friendlist;
            this.sendStatus = sendStatus;
        }

        @Override
        protected Void doInBackground(Void... params) {
            ArrayList<Friend> inviteFriendlist = new ArrayList<>();

            String POST_PARAMS = "param1" + user.username + "&param2=" + user.password;
            Log.d("JJK", POST_PARAMS);
            String php = "sendR.php";

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {

                Log.d("JJK", "CONNECTION ATTEMPT");

                obj = new URL(SERVER_ADDRESS+php);
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;



                JSONArray JSONsender = new JSONArray();
                JSONArray JSONfriendlist = new JSONArray();

                JSONObject jsonuser = new JSONObject();
                jsonuser.put("username", user.username);
                jsonuser.put("showname", user.showname);
                JSONsender.put(jsonuser);


                JSONObject jsonstatus = new JSONObject();

                jsonstatus.put("title", sendStatus.title);
                jsonstatus.put("detail", sendStatus.details);
                jsonstatus.put("location", sendStatus.location);
                jsonstatus.put("timefor", sendStatus.timefor);
                jsonstatus.put("type", sendStatus.type);

                JSONsender.put(jsonstatus);




                for(int i = 0; i < friendlist.size(); i++) {
                    JSONObject friend = new JSONObject();
                    try {
                        friend.put("username", friendlist.get(i).username);
                        friend.put("showname", friendlist.get(i).friendname);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    JSONfriendlist.put(friend);
                }
                JSONObject friendlistJSON = new JSONObject();
                friendlistJSON.put("array", JSONfriendlist);

                JSONsender.put(friendlistJSON);

                OutputStream out = new BufferedOutputStream(con.getOutputStream());
                BufferedWriter os = new BufferedWriter(new OutputStreamWriter(out, "UTF-8"));

                jsonParam = URLEncoder.encode("json", "UTF-8")
                        + "=" + URLEncoder.encode(JSONsender.toString(), "UTF-8");



                //POST STUFF

                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", JSONsender.toString());
                Log.d("JJK", friendlistJSON.toString());
                Log.d("JJK", jsonuser.toString());
                Log.d("JJK", jsonstatus.toString());

                os.write(jsonParam);
                os.flush();

                Log.d("JJK", "BEFORE RESPONSE CODE");
                int responseCode = con.getResponseCode();
                Log.d("JJK", "POST Response Code :: " + responseCode);
                //int responseCode = con.getResponseCode();
                //Log.d("JJK", "POST Response Code :: " + responseCode);
                //Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());

                String jsonReply;
                byte[] bytes = new byte[1];

                outputstream.close();

            }
            catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
            // Log.d("JJK", "RETURNED AND PASSWORD: "+returneduser.username + " : " + returneduser.password);
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            progressDialog.dismiss();
            callback.done(null);


            super.onPostExecute(aVoid);
        }
    }



    public class sendChatToFriendsAsyncTask extends AsyncTask<Void, Void, Void> {
        User user;
        ArrayList<Friend> friendlist;
        GetUserCallback callback;
        ChatStatus sendStatus;

        public sendChatToFriendsAsyncTask(User user, ArrayList<Friend> friendlist,ChatStatus sendStatus, GetUserCallback callback) {
            this.user = user;
            this.callback = callback;
            this.friendlist = friendlist;
            this.sendStatus = sendStatus;
        }

        @Override
        protected Void doInBackground(Void... params) {
            ArrayList<Friend> inviteFriendlist = new ArrayList<>();

            String POST_PARAMS = "param1" + user.username + "&param2=" + user.password;
            Log.d("JJK", POST_PARAMS);
            String php = "sendChatR.php";

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {

                Log.d("JJK", "CONNECTION ATTEMPT");

                obj = new URL(SERVER_ADDRESS+php);
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;



                JSONArray JSONsender = new JSONArray();
                JSONArray JSONfriendlist = new JSONArray();

                JSONObject jsonuser = new JSONObject();
                jsonuser.put("username", user.username);
                jsonuser.put("showname", user.showname);
                JSONsender.put(jsonuser);


                JSONObject jsonstatus = new JSONObject();


                jsonstatus.put("detail", sendStatus.details);
                JSONsender.put(jsonstatus);




                for(int i = 0; i < friendlist.size(); i++) {
                    JSONObject friend = new JSONObject();
                    try {
                        friend.put("username", friendlist.get(i).username);
                        friend.put("showname", friendlist.get(i).friendname);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    JSONfriendlist.put(friend);
                }
                JSONObject friendlistJSON = new JSONObject();
                friendlistJSON.put("array", JSONfriendlist);

                JSONsender.put(friendlistJSON);

                OutputStream out = new BufferedOutputStream(con.getOutputStream());
                BufferedWriter os = new BufferedWriter(new OutputStreamWriter(out, "UTF-8"));

                jsonParam = URLEncoder.encode("json", "UTF-8")
                        + "=" + URLEncoder.encode(JSONsender.toString(), "UTF-8");



                //POST STUFF

                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", JSONsender.toString());
                Log.d("JJK", friendlistJSON.toString());
                Log.d("JJK", jsonuser.toString());
                Log.d("JJK", jsonstatus.toString());

                os.write(jsonParam);
                os.flush();

                Log.d("JJK", "BEFORE RESPONSE CODE");
                int responseCode = con.getResponseCode();
                Log.d("JJK", "POST Response Code :: " + responseCode);
                //int responseCode = con.getResponseCode();
                //Log.d("JJK", "POST Response Code :: " + responseCode);
                //Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());

                String jsonReply;
                byte[] bytes = new byte[1];

                outputstream.close();

            }
            catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
            // Log.d("JJK", "RETURNED AND PASSWORD: "+returneduser.username + " : " + returneduser.password);
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            progressDialog.dismiss();
            callback.done(null);


            super.onPostExecute(aVoid);
        }
    }












    //~~~~~~~ADDING A FRIEND
    // FLAG= 0 MEANS THAT YOU ARE ADDING A FRIEND THAT YOU WERE NOT FRIENDS WITH
    //FLAG = 1 MEANS THAT YOU ARE ADDING A FRIEND THAT ADDED YOU ALREADY

    public class addFriendAsyncTask extends AsyncTask<Void, Void, Void> {
        User user;
        Friend friend;
        GetUserCallback callback;
        int flag;

        public addFriendAsyncTask(User user, Friend friend, GetUserCallback callback, int flag) {
            this.user = user;
            this.callback = callback;
            this.friend = friend;
            this.flag = flag;
        }

        @Override
        protected Void doInBackground(Void... params) {
            ArrayList<Friend> inviteFriendlist = new ArrayList<>();

            String POST_PARAMS = "param1" + user.username + "&param2=" + user.password;
            String userparam = user.username;
            String passwordparam = user.password;
            String friendparam = friend.username;
            Log.d("JJK", POST_PARAMS);
            Log.d("JJK", "username : friendname = " + userparam + friendparam);
            String php = "";

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {
                if(flag == 0){
                    php = "addingFriend.php";
                }
                if(flag == 1){
                    php = "addingBack.php";
                }
                Log.d("JJK", "CONNECTION ATTEMPT");

                obj = new URL(SERVER_ADDRESS+php);
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;
                //jsonParam.put("username", userparam);
                // jsonParam.put("password", passwordparam);


              /*  jsonParam = URLEncoder.encode("user", "UTF-8")
                        + "=" + URLEncoder.encode(userparam, "UTF-8");
                jsonParam += "&"+URLEncoder.encode("friend", "UTF-8")
                        + "=" + URLEncoder.encode(friendparam, "UTF-8");*/

                jsonParam = URLEncoder.encode("user", "UTF-8")
                        + "=" + URLEncoder.encode(userparam, "UTF-8");
                jsonParam += "&" + URLEncoder.encode("friend", "UTF-8")
                        + "=" + URLEncoder.encode(friendparam, "UTF-8");





                //POST STUFF

                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", jsonParam);

                outputstream.write(jsonParam.getBytes(charset));

                //outputstream.write(jsonParam.toString());
                outputstream.flush();

                Log.d("JJK", "BEFORE RESPONSE CODE");
                int responseCode = con.getResponseCode();
                Log.d("JJK", "POST Response Code :: " + responseCode);
                //int responseCode = con.getResponseCode();
                //Log.d("JJK", "POST Response Code :: " + responseCode);
                //Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());

                String jsonReply;
                byte[] bytes = new byte[1];

                outputstream.close();

            }
            catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
            // Log.d("JJK", "RETURNED AND PASSWORD: "+returneduser.username + " : " + returneduser.password);
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            progressDialog.dismiss();
            callback.done(null);


            super.onPostExecute(aVoid);
        }
    }








    //~~~~~~~~~~~~~~~~~~~~~~~~~~GETS THE FRIENDS YOU HAVE FROM YOUR FRIENDS DATABASE

    public class fetchFriendsAsyncTask extends AsyncTask<Void, Void, ArrayList<Friend>> {
        User user;
        GetInviteFriendListCallback callback;
        int flag;

        public fetchFriendsAsyncTask(User user, GetInviteFriendListCallback callback, int flag) {
            this.user = user;
            this.callback = callback;
            this.flag = flag;
        }

        @Override
        protected ArrayList<Friend> doInBackground(Void... params) {
            ArrayList<Friend> inviteFriendlist = new ArrayList<>();


            String POST_PARAMS = "param1" + user.username + "&param2=" + user.password;
            String userparam = user.username;
            String passwordparam = user.password;
            Log.d("JJK", POST_PARAMS);
            String php = "";

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {
                Log.d("JJK", "CONNECTION ATTEMPT");
                if(flag == 0) php = "inviteFriendlist.php";
                if(flag == 1) php = "addFriendlist.php";
                if(flag == 2) php = "showFriendlist.php";
                if(flag == 3) php = "addedMeList.php";
                if(flag == 4) php = "fetchRendezChatNotifChecker.php";
                obj = new URL(SERVER_ADDRESS+php);
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;
                //jsonParam.put("username", userparam);
                // jsonParam.put("password", passwordparam);


                jsonParam = URLEncoder.encode("username", "UTF-8")
                        + "=" + URLEncoder.encode(userparam, "UTF-8");

                //POST STUFF

                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", jsonParam);

                outputstream.write(jsonParam.getBytes(charset));

                //outputstream.write(jsonParam.toString());
                outputstream.flush();
                outputstream.close();
                Log.d("JJK", "BEFORE RESPONSE CODE");
                //int responseCode = con.getResponseCode();
                //Log.d("JJK", "POST Response Code :: " + responseCode);
                //Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());

                String jsonReply;
                byte[] bytes = new byte[1];
                if(con.getResponseCode()==201 || con.getResponseCode()==200)
                {
                    BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
                    jsonReply = in.readLine();


                    //jsonReply = response.toString();
                    Log.d("JJK", jsonReply);
                    JSONArray jsonD = new JSONArray(jsonReply);
                    //JSONObject user = jsonD.getJSONObject(0);
                    //JSONObject pass = jsonD.getJSONObject(1);

                    //jsonReply = convertStreamToString(response);
                    //Log.d("JJK", "INPUT REPLY: "+jsonReply);
                    //JSONArray jarray = new JSONArray(jsonReply);
                    // username = jarray.getString(0);
                    // password = jarray.getString(1);

                    int status = -1;
                    for(int i = 0; i < jsonD.length(); i++) {
                        String username = jsonD.getJSONObject(i).getString("username");
                        String friendname  = jsonD.getJSONObject(i).getString("friendname");
                        String phone = jsonD.getJSONObject(i).getString("phone");
                        String email = jsonD.getJSONObject(i).getString("email");
                        String Fstatus = jsonD.getJSONObject(i).getString("status");
                        Friend friendQuery = new Friend(username, friendname, phone, email,0);
                        inviteFriendlist.add(friendQuery);

                    }

                    //returneduser = new User(username, password);
                    in.close();
                }
                outputstream.close();

            }
            catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
            // Log.d("JJK", "RETURNED AND PASSWORD: "+returneduser.username + " : " + returneduser.password);

            return inviteFriendlist;
        }

        @Override
        protected void onPostExecute(ArrayList<Friend> friendlist) {
            progressDialog.dismiss();
            callback.done(friendlist);


            super.onPostExecute(null);
        }
    }


//#$%^&*(&^$#$%^&*(*&%&%$&^%&*^(*& THIS IS THE PLACE WHERE IF U LOAD AFTER TURNING ON APPS IT CHECKS NOTIFICAITONS THAT COULDNT BE PPICKED UP BY THAT GODDAM SOCKET.IO GODDAM IT


    public class fetchFriendsNotifAsyncTask extends AsyncTask<Void, Void, ArrayList<Friend>> {
        User user;
        GetInviteFriendListCallback callback;

        public fetchFriendsNotifAsyncTask(User user, GetInviteFriendListCallback callback) {
            this.user = user;
            this.callback = callback;
        }

        @Override
        protected ArrayList<Friend> doInBackground(Void... params) {
            ArrayList<Friend> inviteFriendlist = new ArrayList<>();


            String POST_PARAMS = "param1" + user.username + "&param2=" + user.password;
            String userparam = user.username;
            String passwordparam = user.password;
            Log.d("JJK", POST_PARAMS);
            String php = "";

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {
                Log.d("JJK", "CONNECTION ATTEMPT");
                php = "fetchRendezChatNotifChecker.php";
                obj = new URL(SERVER_ADDRESS+php);
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;
                //jsonParam.put("username", userparam);
                // jsonParam.put("password", passwordparam);


                jsonParam = URLEncoder.encode("username", "UTF-8")
                        + "=" + URLEncoder.encode(userparam, "UTF-8");

                //POST STUFF

                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", jsonParam);

                outputstream.write(jsonParam.getBytes(charset));

                //outputstream.write(jsonParam.toString());
                outputstream.flush();
                outputstream.close();
                Log.d("JJK", "BEFORE RESPONSE CODE");
                //int responseCode = con.getResponseCode();
                //Log.d("JJK", "POST Response Code :: " + responseCode);
                //Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());

                String jsonReply;
                byte[] bytes = new byte[1];
                if(con.getResponseCode()==201 || con.getResponseCode()==200)
                {
                    BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
                    jsonReply = in.readLine();


                    //jsonReply = response.toString();
                    Log.d("JJK", jsonReply);
                    JSONArray jsonD = new JSONArray(jsonReply);
                    //JSONObject user = jsonD.getJSONObject(0);
                    //JSONObject pass = jsonD.getJSONObject(1);

                    //jsonReply = convertStreamToString(response);
                    //Log.d("JJK", "INPUT REPLY: "+jsonReply);
                    //JSONArray jarray = new JSONArray(jsonReply);
                    // username = jarray.getString(0);
                    // password = jarray.getString(1);

                    int status = -1;
                    for(int i = 0; i < jsonD.length(); i++) {
                        String username = jsonD.getJSONObject(i).getString("username");
                        String friendname  = jsonD.getJSONObject(i).getString("showname");
                        String phone = jsonD.getJSONObject(i).getString("timestamp");

                        Friend friendQuery = new Friend(username, friendname, phone);
                        inviteFriendlist.add(friendQuery);

                    }

                    //returneduser = new User(username, password);
                    in.close();
                }
                outputstream.close();

            }
            catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
            // Log.d("JJK", "RETURNED AND PASSWORD: "+returneduser.username + " : " + returneduser.password);

            return inviteFriendlist;
        }

        @Override
        protected void onPostExecute(ArrayList<Friend> friendlist) {
            progressDialog.dismiss();
            callback.done(friendlist);


            super.onPostExecute(null);
        }
    }



    //**************~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~SYNCS CONTACTS AND SORTS FRIENDS INTO THE FRIENDS DATABASE

    public class fetchFriendListAsyncTask extends AsyncTask<Void, Void, ArrayList<User>> {
        ArrayList<User> friendlist;
        GetFriendListCallback callback;
        String username;

        public fetchFriendListAsyncTask(ArrayList<User> friendlist, String username, GetFriendListCallback callback) {
            this.friendlist = friendlist;
            this.callback = callback;
            this.username = username;
        }

        @Override
        protected ArrayList<User> doInBackground(Void... params) {


            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {
                Log.d("JJK", "BEGINNING OF TRY STATEMENT");
                Log.d("JJK", "CONNECTION ATTEMPT");
                obj = new URL(SERVER_ADDRESS+"fetchFriends.php");
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;
                //jsonParam.put("username", userparam);
                // jsonParam.put("password", passwordparam);


                JSONArray JSONfriendlist = new JSONArray();
                JSONObject me = new JSONObject();
                me.put("name", username);
                JSONfriendlist.put(me);
                for(int i = 0; i < friendlist.size(); i++) {
                    JSONObject friend = new JSONObject();
                    try {
                        friend.put("name", friendlist.get(i).showname);
                        friend.put("phonenumber", friendlist.get(i).phonenumber);
                        friend.put("email", friendlist.get(i).email);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    JSONfriendlist.put(friend);
                }

                OutputStream out = new BufferedOutputStream(con.getOutputStream());
                BufferedWriter os = new BufferedWriter(new OutputStreamWriter(out, "UTF-8"));
                jsonParam = URLEncoder.encode("json", "UTF-8")
                        + "=" + URLEncoder.encode(JSONfriendlist.toString(), "UTF-8");
                os.write(jsonParam);
                os.close();
                Log.d("JJK", "output for friendlist : "  +JSONfriendlist.toString());
                //outputstream.write(jsonParam.toString());
               // outputstream.flush();
                //outputstream.close();

                Log.d("JJK", "BEFORE RESPONSE CODE");
                int responseCode = con.getResponseCode();
                Log.d("JJK", "POST Response Code :: " + responseCode);
                //Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());

               // outputstream.close();
            }
            catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
            // Log.d("JJK", "RETURNED AND PASSWORD: "+returneduser.username + " : " + returneduser.password);
            ArrayList<User> returnlist = new ArrayList<>();
            return returnlist;
        }

        @Override
        protected void onPostExecute(ArrayList<User> friendlist) {
            progressDialog.dismiss();
            callback.done(friendlist);


            super.onPostExecute(null);
        }
    }



    //THIS SETS A USERS EMAIL SO THEY CAN BE DISCOVERED BYY OTHER FRIENDS

    public class StoreUserEmailAsyncTask extends AsyncTask<Void, Void, Void> {
        User user;
        GetUserCallback userCallback;
        int flag;

        public StoreUserEmailAsyncTask(User user, GetUserCallback userCallback, int flag) {
            this.user = user;
            this.userCallback = userCallback;
            this.flag = flag;
        }

        @Override
        protected Void doInBackground(Void... params) {
            ContentValues contentValues = new ContentValues();
            contentValues.put("username", user.username);
            contentValues.put("password", user.password);

            String POST_PARAMS = "param1" + user.username + "&param2=" + user.password;
            String userparam = user.username;
            String passwordparam = user.password;
            String lastparam = "";
            Log.d("JJK", POST_PARAMS);
            String php = "";
            if(flag == 0){php = "setEmail.php";
                    lastparam = user.email;}
            if(flag == 1){php = "setPhonenumber.php";
                    lastparam = user.phonenumber;}
            if(flag == 2){php = "setShowname.php";
                    lastparam = user.showname;}

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {
                Log.d("JJK", "CONNECTION ATTEMPT");
                obj = new URL(SERVER_ADDRESS+php);
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;
                //jsonParam.put("username", userparam);
                // jsonParam.put("password", passwordparam);


                jsonParam = URLEncoder.encode("username", "UTF-8")
                        + "=" + URLEncoder.encode(userparam, "UTF-8");
                jsonParam += "&" + URLEncoder.encode("password", "UTF-8")
                        + "=" + URLEncoder.encode(passwordparam, "UTF-8");
                jsonParam += "&" + URLEncoder.encode("param", "UTF-8")
                        + "=" + URLEncoder.encode(lastparam, "UTF-8");

                //POST STUFF

                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", jsonParam);

                outputstream.write(jsonParam.getBytes(charset));
                //outputstream.write(jsonParam.toString());
                outputstream.flush();




                outputstream.close();
                Log.d("JJK", "BEFORE RESPONSE CODE");
                int responseCode = con.getResponseCode();
                Log.d("JJK", "POST Response Code :: " + responseCode);
                Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());


            }

            catch (MalformedURLException muex) {
                // TODO Auto-generated catch block
                muex.printStackTrace();
            } catch (IOException ioex){
                ioex.printStackTrace();
            }
            catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            progressDialog.dismiss();
            userCallback.done(null);


            super.onPostExecute(aVoid);
        }
    }



    public class StoreStatusData extends AsyncTask<Void, Void, Void> {
        com.bashlord.loginregister.Status status;
        GetStatusCallback callback;

        public StoreStatusData(com.bashlord.loginregister.Status status, GetStatusCallback callback) {
            this.status = status;
            this.callback = callback;
        }

        @Override
        protected Void doInBackground(Void... params) {
            boolean itworked = false;
            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {
                Log.d("JJK", "CONNECTION ATTEMPT");
                obj = new URL(SERVER_ADDRESS + "newStatus.php");
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;
                //jsonParam.put("username", userparam);
                // jsonParam.put("password", passwordparam);
                String username = status.username;
                String title = status.title;
                String detail = status.details;
                String location = status.location;

                jsonParam = URLEncoder.encode("username", "UTF-8")
                        + "=" + URLEncoder.encode(username, "UTF-8");
                jsonParam += "&" + URLEncoder.encode("title", "UTF-8")
                        + "=" + URLEncoder.encode(title, "UTF-8");
                jsonParam += "&" + URLEncoder.encode("detail", "UTF-8")
                        + "=" + URLEncoder.encode(detail, "UTF-8");
                jsonParam += "&" + URLEncoder.encode("location", "UTF-8")
                        + "=" + URLEncoder.encode(location, "UTF-8");
                jsonParam += "&" + URLEncoder.encode("timefor", "UTF-8")
                        + "=" + URLEncoder.encode(status.timefor, "UTF-8");
                jsonParam += "&" + URLEncoder.encode("type", "UTF-8")
                        + "=" + Integer.toString(status.type);

                //POST STUFF

                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", jsonParam);

                outputstream.write(jsonParam.getBytes(charset));
                //outputstream.write(jsonParam.toString());
                outputstream.flush();


                outputstream.close();
                Log.d("JJK", "BEFORE RESPONSE CODE");
                int responseCode = con.getResponseCode();
                if (responseCode == 200)
                    itworked = true;
                Log.d("JJK", "POST Response Code :: " + responseCode);
                Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());
            } catch (MalformedURLException muex) {
                // TODO Auto-generated catch block
                muex.printStackTrace();
            } catch (IOException ioex) {
                ioex.printStackTrace();
            } catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }

            return null;
        }
        @Override
        protected void onPostExecute(Void aVoid) {
            progressDialog.dismiss();
            callback.done(null);
            super.onPostExecute(aVoid);
        }
    }


//~~~~~~~~~~~~~~~~~DELETING A STATUS
public class deleteStatusDataAsyncTask extends AsyncTask<Void, Void, Void> {
    com.bashlord.loginregister.Status status;
    GetStatusCallback callback;

    public deleteStatusDataAsyncTask(com.bashlord.loginregister.Status status, GetStatusCallback callback) {
        this.status = status;
        this.callback = callback;
    }

    @Override
    protected Void doInBackground(Void... params) {
        boolean itworked = false;
        URL obj = null;
        HttpURLConnection con = null;
        String charset = "UTF-8";
        try {
            Log.d("JJK", "CONNECTION ATTEMPT");
            obj = new URL(SERVER_ADDRESS + "deleteStatus.php");
            con = (HttpURLConnection) obj.openConnection();


            String userpass = "johnjink" + ":" + "coolio15";

            con.setRequestProperty("Authorization", userpass);


            Log.d("JJK", "openconnection " + obj);
            con.setDoOutput(true);
            con.setRequestProperty("Content-Type", "application/json");
            con.setRequestProperty("charset", "utf-8");
            con.setRequestProperty("Accept", "application/json");
            con.setRequestProperty("Accept-Charset", charset);
            con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

            con.setConnectTimeout(CONNECTION_TIMEOUT);
            con.setRequestMethod("POST");
            Log.d("JJK", "right before connect");

            //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
            con.connect();

            Log.d("JJK", "CONNECTION DONE");

            String jsonParam = null;
            //jsonParam.put("username", userparam);
            // jsonParam.put("password", passwordparam);
            String username = status.username;
            String title = status.title;
            String detail = status.details;
            String location = status.location;

            jsonParam = URLEncoder.encode("username", "UTF-8")
                    + "=" + URLEncoder.encode(username, "UTF-8");
            jsonParam += "&" + URLEncoder.encode("title", "UTF-8")
                    + "=" + URLEncoder.encode(title, "UTF-8");
            jsonParam += "&" + URLEncoder.encode("detail", "UTF-8")
                    + "=" + URLEncoder.encode(detail, "UTF-8");
            jsonParam += "&" + URLEncoder.encode("location", "UTF-8")
                    + "=" + URLEncoder.encode(location, "UTF-8");

            //POST STUFF

            DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
            Log.d("JJK", jsonParam);

            outputstream.write(jsonParam.getBytes(charset));
            //outputstream.write(jsonParam.toString());
            outputstream.flush();


            outputstream.close();
            Log.d("JJK", "BEFORE RESPONSE CODE");
            int responseCode = con.getResponseCode();
            if (responseCode == 200)
                itworked = true;
            Log.d("JJK", "POST Response Code :: " + responseCode);
            Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());
        } catch (MalformedURLException muex) {
            // TODO Auto-generated catch block
            muex.printStackTrace();
        } catch (IOException ioex) {
            ioex.printStackTrace();
        } catch (Exception e) {
            Log.d("JJK", "EXCEPTION FORSOEM SHIT");
            e.printStackTrace();
            Log.d("JJK", "There is error in this code");

        }

        return null;
    }
    @Override
    protected void onPostExecute(Void aVoid) {
//        progressDialog.dismiss();
        callback.done(null);
        super.onPostExecute(aVoid);
    }
}










//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~STORING A USER

    public class StoreUserDataAsyncTask extends AsyncTask<Void, Void, Void> {
        User user;
        GetUserCallback userCallback;

        public StoreUserDataAsyncTask(User user, GetUserCallback userCallback) {
            this.user = user;
            this.userCallback = userCallback;
        }

        @Override
        protected Void doInBackground(Void... params) {
            ContentValues contentValues = new ContentValues();
            contentValues.put("username", user.username);
            contentValues.put("password", user.password);

            String POST_PARAMS = "param1" + user.username + "&param2=" + user.password;
            String userparam = user.username;
            String passwordparam = user.password;
            Log.d("JJK", POST_PARAMS);

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {
                Log.d("JJK", "CONNECTION ATTEMPT");
                obj = new URL(SERVER_ADDRESS+"register.php");
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;
                //jsonParam.put("username", userparam);
               // jsonParam.put("password", passwordparam);


                jsonParam = URLEncoder.encode("username", "UTF-8")
                        + "=" + URLEncoder.encode(userparam, "UTF-8");
                jsonParam += "&" + URLEncoder.encode("password", "UTF-8")
                        + "=" + URLEncoder.encode(passwordparam, "UTF-8");

                //POST STUFF

                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", jsonParam);

                outputstream.write(jsonParam.getBytes(charset));
                //outputstream.write(jsonParam.toString());
                outputstream.flush();




                outputstream.close();
                Log.d("JJK", "BEFORE RESPONSE CODE");
                int responseCode = con.getResponseCode();
                Log.d("JJK", "POST Response Code :: " + responseCode);
                Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());


            }

         catch (MalformedURLException muex) {
            // TODO Auto-generated catch block
            muex.printStackTrace();
        } catch (IOException ioex){
            ioex.printStackTrace();
        }
        catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
            e.printStackTrace();
            Log.d("JJK", "There is error in this code");

            }
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            progressDialog.dismiss();
            userCallback.done(null);


            super.onPostExecute(aVoid);
        }
    }
    //************FETCHING STATUSES WHEN LOGGING IN

    public class fetchStatusDataAsyncTask extends AsyncTask<Void, Void, ArrayList<com.bashlord.loginregister.Status>> {
        User user;
        GetStatusArrayCallback callback;

        public fetchStatusDataAsyncTask(User user, GetStatusArrayCallback callback) {
            this.user = user;
            this.callback = callback;
        }

        @Override
        protected ArrayList<com.bashlord.loginregister.Status> doInBackground(Void... params) {
            ArrayList<com.bashlord.loginregister.Status> returnedStatus = new ArrayList<com.bashlord.loginregister.Status>();
            String username = null;
            String title = null;
            String detail = null;
            String location = null;
            String POST_PARAMS = "param1" + user.username + "&param2=" + user.password;
            String userparam = user.username;
            String passwordparam = user.password;
            Log.d("JJK", POST_PARAMS);

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {
                Log.d("JJK", "CONNECTION ATTEMPT");
                obj = new URL(SERVER_ADDRESS+"fetchStatus.php");
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;
                //jsonParam.put("username", userparam);
                // jsonParam.put("password", passwordparam);


                jsonParam = URLEncoder.encode("username", "UTF-8")
                        + "=" + URLEncoder.encode(userparam, "UTF-8");

                //POST STUFF

                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", jsonParam);

                outputstream.write(jsonParam.getBytes(charset));

                //outputstream.write(jsonParam.toString());
                outputstream.flush();
                outputstream.close();

                Log.d("JJK", "BEFORE RESPONSE CODE");
                //int responseCode = con.getResponseCode();
                //Log.d("JJK", "POST Response Code :: " + responseCode);
                //Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());

                String jsonReply;
                byte[] bytes = new byte[1];
                if(con.getResponseCode()==201 || con.getResponseCode()==200)
                {
                    BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
                    jsonReply = in.readLine();


                    //jsonReply = response.toString();
                    Log.d("JJK", jsonReply.toString());
                    JSONArray jsonD = new JSONArray(jsonReply);
                    //JSONObject user = jsonD.getJSONObject(0);
                    //JSONObject pass = jsonD.getJSONObject(1);

                    //jsonReply = convertStreamToString(response);
                    //Log.d("JJK", "INPUT REPLY: "+jsonReply);
                    //JSONArray jarray = new JSONArray(jsonReply);
                    // username = jarray.getString(0);
                    // password = jarray.getString(1);
                    int id;
                    for(int i = 0; i < jsonD.length(); i++) {
                        id =  jsonD.getJSONObject(i).getInt("id");
                        username = jsonD.getJSONObject(i).getString("username");
                        title = jsonD.getJSONObject(i).getString("title");
                        detail = jsonD.getJSONObject(i).getString("detail");
                        location = jsonD.getJSONObject(i).getString("location");
                        String timeset = jsonD.getJSONObject(i).getString("timeset");
                        String timefor = jsonD.getJSONObject(i).getString("timefor");
                        int type = jsonD.getJSONObject(i).getInt("type");
                        int visable = jsonD.getJSONObject(i).getInt("visable");
                        JSONArray fromuser = jsonD.getJSONObject(i).getJSONArray("fromuser");
                        ArrayList fu = new ArrayList<com.bashlord.loginregister.Status>();
                        if (fromuser != null) {
                            for (int j=0;i<fromuser.length();j++){

                                fromuser u = new fromuser(fromuser.getJSONObject(j).getString("fromuser"), fromuser.getJSONObject(j).getInt("response"));
                                fu.add(u);

                            }
                        }

                        com.bashlord.loginregister.Status statusQuery = new com.bashlord.loginregister.Status(id,username, title, detail, location, timeset, timefor, type,fu, visable);
                        returnedStatus.add(statusQuery);
                        Log.d("JJK", "FIRST AND LAST: " + username + " : " + title + " : " + detail + " : " + location+ "\n");
                    }

                    //returneduser = new User(username, password);
                    in.close();
                }
                outputstream.close();



            }

            catch (MalformedURLException muex) {
                // TODO Auto-generated catch block
                muex.printStackTrace();
            } catch (IOException ioex){
                ioex.printStackTrace();
            }
            catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
            // Log.d("JJK", "RETURNED AND PASSWORD: "+returneduser.username + " : " + returneduser.password);
            return returnedStatus;
        }

        protected void onPostExecute(ArrayList<com.bashlord.loginregister.Status> returnedStatus) {
            super.onPostExecute(returnedStatus);
            //progressDialog.dismiss();
            callback.done(returnedStatus);

        }
    }

//******************************FETCH USED WHEN LOGGING IN
    public class fetchUserDataAsyncTask extends AsyncTask<Void, Void, ArrayList<Friend>> {
        User user;
        OnLoginInfo userCallback;

        public fetchUserDataAsyncTask(User user, OnLoginInfo userCallback) {
            this.user = user;
            this.userCallback = userCallback;
        }

        @Override
        protected ArrayList<Friend> doInBackground(Void... params) {
            ArrayList<Friend> returneduser = null;
            String username = null;
            String password = null;
            String email = null;
            String phonenumber = null;
            String showname = null;
            String POST_PARAMS = "param1" + user.username + "&param2=" + user.password;
            String userparam = user.username;
            String passwordparam = user.password;
            Log.d("JJK", POST_PARAMS);

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {
                Log.d("JJK", "CONNECTION ATTEMPT");
                obj = new URL(SERVER_ADDRESS+"FetchUserData.php");
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;
                //jsonParam.put("username", userparam);
                // jsonParam.put("password", passwordparam);


                jsonParam = URLEncoder.encode("username", "UTF-8")
                        + "=" + URLEncoder.encode(userparam, "UTF-8");
                jsonParam += "&" + URLEncoder.encode("password", "UTF-8")
                        + "=" + URLEncoder.encode(passwordparam, "UTF-8");

                //POST STUFF

                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", jsonParam);

                outputstream.write(jsonParam.getBytes(charset));
                //outputstream.write(jsonParam.toString());
                outputstream.flush();
                outputstream.close();

                Log.d("JJK", "BEFORE RESPONSE CODE");
                //int responseCode = con.getResponseCode();
                //Log.d("JJK", "POST Response Code :: " + responseCode);
                //Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());

                String jsonReply;
                byte[] bytes = new byte[1];
                if(con.getResponseCode()==201 || con.getResponseCode()==200) {
                    BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
                    jsonReply = in.readLine();


                    //jsonReply = response.toString();
                    Log.d("JJK", jsonReply);
                    JSONArray jsonD = new JSONArray(jsonReply);

                    if (!jsonD.getJSONObject(0).isNull("username") && !jsonD.getJSONObject(0).isNull("password")) {
                        returneduser = new ArrayList<Friend>();
                        username = jsonD.getJSONObject(0).getString("username");
                        password = jsonD.getJSONObject(0).getString("password");
                        String emailp = "Click here to register an email!";
                        String phonenumberp = "Click here to register an phonenumber!";
                        String shownamep = "Click here to make a Username for other people!";

                        if(!jsonD.getJSONObject(0).isNull("email")) {
                            email = jsonD.getJSONObject(0).getString("email");
                        }else email = emailp;

                        if(!jsonD.getJSONObject(0).isNull("phonenumber")) {
                            phonenumber = jsonD.getJSONObject(0).getString("phonenumber");
                        }else phonenumber = phonenumberp;

                        if(!jsonD.getJSONObject(0).isNull("showname")) {
                            showname = jsonD.getJSONObject(0).getString("showname");
                        }else showname = shownamep;
                        Friend returneduser1 = new Friend(username, showname, phonenumber, email, 0);
                        returneduser.add(returneduser1);
                        Log.d("JJK", "FIRST AND LAST: " + username + " : " + password);


                        for (int i = 1; i < jsonD.length(); i++) {
                            String title;
                            String detail;
                            username = jsonD.getJSONObject(i).getString("frienduser");
                            title = jsonD.getJSONObject(i).getString("friendname");
                             if (!jsonD.getJSONObject(i).isNull("timestamp")) {
                                  detail = jsonD.getJSONObject(i).getString("timestamp");
                                  Log.d("JJK", "it is not null" + detail);
                            }
                             else{
                                  detail = "1970-01-01 01:01:01";
                                  Log.d("JJK", "it is null" + detail);
                            }
                            Friend statusQuery = new Friend(username, title, detail);
                            //((AppDelegate)getApplication()).makingFriendlist(statusQuery);
                            Log.d("JJK", "FIRST AND LAST: " + username + " : " + title + " : " +"\n");
                            returneduser.add(statusQuery);
                    }
                }

                    //returneduser = new User(username, password);
                    in.close();
                }
                outputstream.close();



            }

            catch (MalformedURLException muex) {
                // TODO Auto-generated catch block
                muex.printStackTrace();
            } catch (IOException ioex){
                ioex.printStackTrace();
            }
            catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
           // Log.d("JJK", "RETURNED AND PASSWORD: "+returneduser.username + " : " + returneduser.password);
            return returneduser;
        }

        protected void onPostExecute(ArrayList<Friend> returneduser) {
            super.onPostExecute(returneduser);
            progressDialog.dismiss();
            userCallback.done(returneduser);

        }
    }

    public class fetchFriendStatusDataAsyncTask extends AsyncTask<Void, Void, ArrayList<com.bashlord.loginregister.Status>> {
        User user;
        GetStatusArrayCallback callback;

        public fetchFriendStatusDataAsyncTask(User user, GetStatusArrayCallback callback) {
            this.user = user;
            this.callback = callback;
        }

        @Override
        protected ArrayList<com.bashlord.loginregister.Status> doInBackground(Void... params) {
            ArrayList<com.bashlord.loginregister.Status> returnedStatus = new ArrayList<com.bashlord.loginregister.Status>();
            String username = null;
            String title = null;
            String detail = null;
            String location = null;
            String POST_PARAMS = "param1" + user.username + "&param2=" + user.password;
            String userparam = user.username;
            String passwordparam = user.password;
            Log.d("JJK", POST_PARAMS);

            URL obj = null;
            HttpURLConnection con = null;
            String charset = "UTF-8";
            try {
                Log.d("JJK", "CONNECTION ATTEMPT");
                obj = new URL(SERVER_ADDRESS + "fetchFriendStatus.php");
                con = (HttpURLConnection) obj.openConnection();


                String userpass = "johnjink" + ":" + "coolio15";

                con.setRequestProperty("Authorization", userpass);


                Log.d("JJK", "openconnection " + obj);
                con.setDoOutput(true);
                con.setRequestProperty("Content-Type", "application/json");
                con.setRequestProperty("charset", "utf-8");
                con.setRequestProperty("Accept", "application/json");
                con.setRequestProperty("Accept-Charset", charset);
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=" + charset);

                con.setConnectTimeout(CONNECTION_TIMEOUT);
                con.setRequestMethod("POST");
                Log.d("JJK", "right before connect");

                //Log.d("JJK", "POST Response Code :: " + con.getResponseCode());
                con.connect();

                Log.d("JJK", "CONNECTION DONE");

                String jsonParam = null;
                //jsonParam.put("username", userparam);
                // jsonParam.put("password", passwordparam);


                jsonParam = URLEncoder.encode("username", "UTF-8")
                        + "=" + URLEncoder.encode(userparam, "UTF-8");

                //POST STUFF

                DataOutputStream outputstream = new DataOutputStream(con.getOutputStream());
                Log.d("JJK", jsonParam);

                outputstream.write(jsonParam.getBytes(charset));

                //outputstream.write(jsonParam.toString());
                outputstream.flush();
                outputstream.close();

                Log.d("JJK", "BEFORE RESPONSE CODE");
                //int responseCode = con.getResponseCode();
                //Log.d("JJK", "POST Response Code :: " + responseCode);
                //Log.d("JJK", "Response MEssage:: " + con.getResponseMessage());

                String jsonReply;
                byte[] bytes = new byte[1];
                if (con.getResponseCode() == 201 || con.getResponseCode() == 200) {
                    BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
                    jsonReply = in.readLine();


                    //jsonReply = response.toString();
                    Log.d("JJK", jsonReply.toString());
                    JSONArray jsonD = new JSONArray(jsonReply);
                    //JSONObject user = jsonD.getJSONObject(0);
                    //JSONObject pass = jsonD.getJSONObject(1);

                    //jsonReply = convertStreamToString(response);
                    //Log.d("JJK", "INPUT REPLY: "+jsonReply);
                    //JSONArray jarray = new JSONArray(jsonReply);
                    // username = jarray.getString(0);
                    // password = jarray.getString(1);
                    for (int i = 0; i < jsonD.length(); i++) {
                        username = jsonD.getJSONObject(i).getString("username");
                        title = jsonD.getJSONObject(i).getString("title");
                        detail = jsonD.getJSONObject(i).getString("detail");
                        location = jsonD.getJSONObject(i).getString("location");
                        String timeset = jsonD.getJSONObject(i).getString("timeset");
                        int visable = jsonD.getJSONObject(i).getInt("visable");



                        String timefor;
                        if(jsonD.getJSONObject(i).get("timefor") instanceof String){
                            timefor = null;
                        }else {
                            timefor = jsonD.getJSONObject(i).getString("timefor");
                        }
                        int type = jsonD.getJSONObject(i).getInt("type");
                        JSONArray fromuser = jsonD.getJSONObject(i).getJSONArray("fromuser");
                        ArrayList fu = new ArrayList<com.bashlord.loginregister.Status>();
                        if (fromuser != null) {
                            for (int j = 0; i < fromuser.length(); j++) {

                                fromuser u = new fromuser(fromuser.getJSONObject(j).getString("fromuser"), fromuser.getJSONObject(j).getInt("response"));
                                fu.add(u);

                            }
                        }

                        com.bashlord.loginregister.Status statusQuery = new com.bashlord.loginregister.Status(username, title, detail, location, timeset, timefor, type, fu, visable);
                        returnedStatus.add(statusQuery);
                        Log.d("JJK", "FIRST AND LAST: " + username + " : " + title + " : " + detail + " : " + location + "\n");
                    }

                    //returneduser = new User(username, password);
                    in.close();
                }
                outputstream.close();


            } catch (MalformedURLException muex) {
                // TODO Auto-generated catch block
                muex.printStackTrace();
            } catch (IOException ioex) {
                ioex.printStackTrace();
            } catch (Exception e) {
                Log.d("JJK", "EXCEPTION FORSOEM SHIT");
                e.printStackTrace();
                Log.d("JJK", "There is error in this code");

            }
            // Log.d("JJK", "RETURNED AND PASSWORD: "+returneduser.username + " : " + returneduser.password);
            return returnedStatus;
        }
    }


    private static String convertStreamToString(InputStream is) {

        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        StringBuilder sb = new StringBuilder();

        String line = null;
        try {
            while ((line = reader.readLine()) != null) {
                sb.append(line + "\n");
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                is.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return sb.toString();
    }


}