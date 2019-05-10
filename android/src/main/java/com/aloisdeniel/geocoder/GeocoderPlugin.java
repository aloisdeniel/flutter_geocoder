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

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * NotAvailableException
 */
class NotAvailableException extends Exception {
  NotAvailableException() {}
}

/**
 * GeocoderPlugin
 */
public class GeocoderPlugin implements MethodCallHandler {

  private Geocoder geocoder;

  public GeocoderPlugin(Context context) {

    this.geocoder = new Geocoder(context);
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "github.com/aloisdeniel/geocoder");
    channel.setMethodCallHandler(new GeocoderPlugin(registrar.context()));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("findAddressesFromQuery")) {
      String address = (String) call.argument("address");
      findAddressesFromQuery(address, result);
    }
    else if (call.method.equals("findAddressesFromCoordinates")) {
      float latitude = ((Number) call.argument("latitude")).floatValue();
      float longitude = ((Number) call.argument("longitude")).floatValue();
      findAddressesFromCoordinates(latitude,longitude, result);
    } else {
      result.notImplemented();
    }
  }

  private void assertPresent() throws NotAvailableException {
    if (!geocoder.isPresent()) {
      throw new NotAvailableException();
    }
  }

  private void findAddressesFromQuery(final String address, final Result result) {

    final GeocoderPlugin plugin = this;
    new AsyncTask<Void, Void, Void>()
    {
      @Override
      protected Void doInBackground(Void... params)
      {
        try {
          plugin.assertPresent();
          List<Address> addresses = geocoder.getFromLocationName(address, 20);
	      if (addresses.size() == 0) {
	        throw new NotAvailableException();
	      }
          result.success(createAddressMapList(addresses));
        }
        catch(IOException ex) {
          result.error("failed", ex.toString(), null);
        }
        catch(NotAvailableException ex) {
          result.error("not_available", ex.toString(), null);
        }
        return null;
      }

      @Override
      protected void onPostExecute(Void result)
      {
        super.onPostExecute(result);
      }
    }.execute();
  }

  private void findAddressesFromCoordinates(final float latitude, final float longitude, final Result result) {

    final GeocoderPlugin plugin = this;
    new AsyncTask<Void, Void, Void>()
    {
      @Override
      protected Void doInBackground(Void... params)
      {
        try {
          plugin.assertPresent();
          List<Address> addresses = geocoder.getFromLocation(latitude, longitude, 20);
	      if (addresses.size() == 0) {
  		    throw new NotAvailableException();
	      }
          result.success(createAddressMapList(addresses));
        } catch (IOException ex) {
          result.error("failed", ex.toString(), null);
        } catch (NotAvailableException ex) {
          result.error("not_available", ex.toString(), null);
        }
        return null;
      }

      @Override
      protected void onPostExecute(Void result)
      {
        super.onPostExecute(result);
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

