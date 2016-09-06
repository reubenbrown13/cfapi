package com.cfapi.[[*apiName*]];

import java.util.ArrayList;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.FragmentActivity;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import com.cfapi.[[*apiName*]].DTO.[[*viewNameUC*]]DTO;
import com.cfapi.[[*apiName*]].WS.[[*viewNameUC*]]WS;

public class MainActivity extends FragmentActivity
{

   ArrayList<[[*viewNameUC*]]DTO> [[*viewNameLC*]]List=new ArrayList<[[*viewNameUC*]]DTO>();
   GoogleMap supportMap;

   @Override
   protected void onCreate(Bundle savedInstanceState)
   {
      super.onCreate(savedInstanceState);
      setContentView(R.layout.activity_main);

      int resultCode=GooglePlayServicesUtil.isGooglePlayServicesAvailable(getApplicationContext());

      if (resultCode == ConnectionResult.SUCCESS)
      {

         FragmentManager fmanager=getSupportFragmentManager();
         Fragment fragment=fmanager.findFragmentById(R.id.map);
         SupportMapFragment supportmapfragment=(SupportMapFragment) fragment;
         supportMap=supportmapfragment.getMap();

         supportMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);

         supportMap.setMyLocationEnabled(true);

         LatLng latlng=new LatLng([[*initialMapLatitude*]], [[*initialMapLongitude*]]);

         CameraPosition cameraPosition=new CameraPosition.Builder().target(latlng).zoom(10).build();
         supportMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));

      }
      else
      {
         try
         {
            int RQS_GooglePlayServices=1;

            GooglePlayServicesUtil.getErrorDialog(resultCode, this, RQS_GooglePlayServices);
         }
         catch (Exception erro)
         {
            finish();
         }
      }

      // Start webService consumption.
      showItems();

   }

   private void showItems()
   {
      new Thread()
      {
         public void run()
         {

            try
            {
               String token="[[*accessToken*]]";

               [[*viewNameUC*]]WS [[*viewNameLC*]]WS=new [[*viewNameUC*]]WS();
               [[*viewNameLC*]]List=[[*viewNameLC*]]WS.get[[*viewNameUC*]]List(token);

               Bundle bundle=new Bundle();
               bundle.putString("message", "ok");

               Message message=new Message();
               message.setData(bundle);
               messageHandler.sendMessage(message);

            }
            catch (Exception e)
            {
               e.printStackTrace();
            }

         }
      }.start();

   }

   public Handler messageHandler=new Handler()
   {
      public void handleMessage(Message message)
      {
         String result=(String) message.getData().getString("message");

         if (result == "ok")
         {
            MarkerOptions markeroptions=new MarkerOptions();

            for ([[*viewNameUC*]]DTO item : [[*viewNameLC*]]List)
            {

               // Draw markers on the map.
               markeroptions.position(new LatLng(Double.valueOf(item.getLatitude()), Double.valueOf(item.getLongitude())));
               markeroptions.title(item.get[[*searchFilterUC*]]());
               markeroptions.draggable(false);

               supportMap.addMarker(markeroptions);

            }

         }
      }
   };

}
