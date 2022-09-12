package com.example.test_project;

import static android.app.PendingIntent.FLAG_UPDATE_CURRENT;

import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.IBinder;

public class MusicService extends Service {
    public MusicService(String uri) {
        this.uri = uri;
    }
    private final String uri;

    private MediaPlayer player;


    @Override
    public IBinder onBind(Intent intent) {
        throw new UnsupportedOperationException("Not yet implemented");
    }

    @Override
    public void onCreate() {
        MyReceiver receiver = new MyReceiver();
        registerReceiver(receiver, new IntentFilter("PlayPause"));
        player = MediaPlayer.create(this, Uri.parse(uri));
        super.onCreate();
    }

    @Override
    public int onStartCommand(Intent startIntent, int flags, int startId) {
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent =
                PendingIntent.getActivity(this, 0, notificationIntent, 0);
        @SuppressLint("UnspecifiedImmutableFlag") PendingIntent pPPendingIntent =
                PendingIntent.getBroadcast(this, 0, new Intent("PlayPause"),
                        FLAG_UPDATE_CURRENT);
        Notification notification =
                new Notification.Builder(this)
                        .setContentTitle("Lecture en cours")
                        .setContentText("Tahir ve Nafess")
                        .setSmallIcon(R.drawable.launch_background)
                        .addAction(R.drawable.launch_background, "Play/Pause", pPPendingIntent)
                        .setContentIntent(pendingIntent)
                        .setPriority(Notification.PRIORITY_MAX)
                        .build();
        startForeground(110, notification);
        player.start();
        return START_STICKY;
    }

    class MyReceiver extends BroadcastReceiver{
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action.equals("PlayPause")) {
                if(player.isPlaying()) {player.pause();}
                else {player.start();}
            }
        }
    }
}

