package com.bashlord.loginregister;

/**
 * Created by JJK on 8/10/15.
 */
public class Friend implements Comparable<Friend>{
    String username, friendname, phone, email, location;
    int status, chatCount, rendezCount;
    boolean selected = false;
    boolean notification = false;
    String time;
    java.sql.Timestamp timestamp;//this will be the new loctime
    public Friend(String username, String friendname, String time){
        this.username = username;
        this.friendname = friendname;
        this.time = time;
    }

    public Friend(String username, String friendname, java.sql.Timestamp time){
        this.username = username;
        this.friendname = friendname;
        this.timestamp = time;
    }
    public Friend(String username, String friendname, String phone, String email, int status){
        this.username = username;
        this.friendname = friendname;
        this.phone = phone;
        this.email = email;
        this.status = status;
    }

    public Friend(String username, String friendname, String time, java.sql.Timestamp loctime, String location){
        this.username = username;
        this.friendname = friendname;
        this.time = time;
        this.timestamp = loctime;
        this.location = location;
    }

    public String getUsername() {
        return username;
    }
    public String getShowname() {
        return friendname;
    }


    public boolean isSelected() {
        return selected;
    }
    public void setSelected(boolean selected) {
        this.selected = selected;
    }
    public boolean notifOn() {
        return notification;
    }
    public void notifChange(boolean selected) {
        this.notification = selected;
    }

    @Override
    public int compareTo(Friend another) {
        java.sql.Timestamp currentTime = java.sql.Timestamp.valueOf(this.time);
        java.sql.Timestamp friendTime = java.sql.Timestamp.valueOf(another.time);
        if(currentTime.getTime() < friendTime.getTime()){
            return 0;
        }else return 1;
    }
}
