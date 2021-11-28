package com.aloisdeniel.geocoder;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.io.IOException;
import java.lang.Exception;
import android.content.Context;
import android.location.Address;
import android.location.Geocoder;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;

import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * NotAvailableException
 */
class NotAvailableException extends Exception {
  NotAvailableException() {}
}

/**
 * GeocoderPlugin
 */
public class GeocoderPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;

  private Context context;
  private Geocoder geocoder;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "github.com/aloisdeniel/geocoder");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
    this.geocoder = new Geocoder(context);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("findAddressesFromQuery")) {
      String address = (String) call.argument("address");
      findAddressesFromQuery(address, result);
    } else if (call.method.equals("findAddressesFromCoordinates")) {
      float latitude = ((Number) call.argument("latitude")).floatValue();
      float longitude = ((Number) call.argument("longitude")).floatValue();
      findAddressesFromCoordinates(latitude,longitude, result);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private void assertPresent() throws NotAvailableException {
    if (!geocoder.isPresent()) {
      throw new NotAvailableException();
    }
  }

  private void findAddressesFromQuery(final String address, final Result result) {

    final GeocoderPlugin plugin = this;
    new AsyncTask<Void, Void, List<Address>>() {
        @Override
        protected List<Address> doInBackground(Void... params) {
            try {
                plugin.assertPresent();
                return geocoder.getFromLocationName(address, 20);
            } catch (IOException ex) {
                return null;
            } catch (NotAvailableException ex) {
                return new ArrayList<>();
            }
        }

        @Override
        protected void onPostExecute(List<Address> addresses) {
            if (addresses != null) {
                if (addresses.isEmpty())
                    result.error("not_available", "Empty", null);
                else
                    result.success(createAddressMapList(addresses));
            } else
                result.error("failed", "Failed", null);
        }
    }.execute();
  }

  private void findAddressesFromCoordinates(final float latitude, final float longitude, final Result result) {
    final GeocoderPlugin plugin = this;
    new AsyncTask<Void, Void, List<Address>>() {
        @Override
        protected List<Address> doInBackground(Void... params) {
            try {
                plugin.assertPresent();
                return geocoder.getFromLocation(latitude, longitude, 20);
            } catch (IOException ex) {
                return null;
            } catch (NotAvailableException ex) {
                return new ArrayList<>();
            }
        }

        @Override
        protected void onPostExecute(List<Address> addresses) {
            if (addresses != null) {
                if (addresses.isEmpty())
                    result.error("not_available", "Empty", null);
                else
                    result.success(createAddressMapList(addresses));
            } else
                result.error("failed", "Failed", null);
        }
    }.execute();
  }

  private Map<String, Object> createCoordinatesMap(Address address) {

    if(address == null)
      return null;

    Map<String, Object> result = new HashMap<String, Object>();

    result.put("latitude", address.getLatitude());
    result.put("longitude", address.getLongitude());

    return result;
  }

  private Map<String, Object> createAddressMap(Address address) {

    if(address == null)
      return null;

    // Creating formatted address
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i <= address.getMaxAddressLineIndex(); i++) {
      if (i > 0) {
        sb.append(", ");
      }
      sb.append(address.getAddressLine(i));
    }

    Map<String, Object> result = new HashMap<String, Object>();

    result.put("coordinates", createCoordinatesMap(address));
    result.put("featureName", address.getFeatureName());
    result.put("countryName", address.getCountryName());
    result.put("countryCode", address.getCountryCode());
    result.put("locality", address.getLocality());
    result.put("subLocality", address.getSubLocality());
    result.put("thoroughfare", address.getThoroughfare());
    result.put("subThoroughfare", address.getSubThoroughfare());
    result.put("adminArea", address.getAdminArea());
    result.put("subAdminArea", address.getSubAdminArea());
    result.put("addressLine", sb.toString());
    result.put("postalCode", address.getPostalCode());

    return result;
  }

  private List<Map<String, Object>> createAddressMapList(List<Address> addresses) {

    if(addresses == null)
      return new ArrayList<Map<String, Object>>();

    List<Map<String, Object>> result = new ArrayList<Map<String, Object>>(addresses.size());

    for (Address address : addresses) {
      result.add(createAddressMap(address));
    }

    return result;
  }
}

