package touchesbegan.com.rastreomx;

import touchesbegan.com.rastreomx.R;
import android.app.Activity;
import android.app.ActionBar;
import android.app.Fragment;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Toast;
import android.os.Build;

public class Masinfo extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_masinfo);
		
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, 
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
		
		ActionBar bar = getActionBar();
		bar.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#F05157")));

	}
	
	//ir a facebook
		public void irAfacebook(View v){
			Intent itImplicito = new Intent(Intent.ACTION_VIEW, 
					Uri.parse("http://www.facebook.com/rastreoMX"));
			startActivity(itImplicito);	
		}
	//ir a twitter	
		public void irAtwitter(View v){
			Intent itImplicito = new Intent(Intent.ACTION_VIEW, 
					Uri.parse("http://www.Twitter.com/@rastreomx"));
			startActivity(itImplicito);	
		}
	//ir a correo
		public void irAcorreo(View v){
			this.sendFeedback();
		}
		
		/**
		 * Report an issue, suggest a feature, or send feedback.
		 */
		private void sendFeedback() {

			// Checks if the device is connected to the Internet.
			if (isDeviceConnected()) {

				// Set the action to be performed
				Intent sendIntent = new Intent();
				sendIntent.setAction(Intent.ACTION_SEND);

				// E-mail addresses that should be delivered to.
				sendIntent.putExtra(Intent.EXTRA_EMAIL,
						new String[] { "rastreomx@yahoo.com" });

				// Set the subject line of a message
				sendIntent.putExtra(Intent.EXTRA_SUBJECT, "RastreoMx");

				// Set the data type of the message
				sendIntent.setType("plain/text");
				startActivity(Intent.createChooser(sendIntent,
						"Report an issue, suggest a feature, or send feedback"));

			} else

				Toast.makeText(getApplicationContext(),
						"Your device is not connected to the Internet",
						Toast.LENGTH_LONG).show();
		}

		/**
		 * Checks if the device is connected to the Internet.
		 * 
		 * @param context
		 *            application context
		 * @return if the device is connected true, otherwise false.
		 */
		private boolean isDeviceConnected() {

			final ConnectivityManager connectManager = (ConnectivityManager) getApplicationContext()
					.getSystemService(Context.CONNECTIVITY_SERVICE);
			return (connectManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE)
					.getState() == NetworkInfo.State.CONNECTED || connectManager
					.getNetworkInfo(ConnectivityManager.TYPE_WIFI).getState() == NetworkInfo.State.CONNECTED);
		}


	@Override
	public boolean onCreateOptionsMenu(Menu menu) {

		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.masinfo, menu);
		return true;
	}

	
}
