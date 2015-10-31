package touchesbegan.com.rastreomx;

import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class CustomBaseAdapter extends BaseAdapter {
	Context context;
	List<List_paquete> rowItems;
	
	public CustomBaseAdapter(Context context, List<List_paquete> items){
		this.context = context;
		this.rowItems = items;
	}
	
	private class ViewHolder { 
		ImageView imageView;
		TextView textClave;
	}
	
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return rowItems.size();
	}

	@Override
	public Object getItem(int arg0) {
		// TODO Auto-generated method stub
		return rowItems.get(arg0);
	}

	@Override
	public long getItemId(int arg0) {
		// TODO Auto-generated method stub
		return rowItems.indexOf(getItem(arg0));
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		ViewHolder holder = null;
		LayoutInflater mInflater = (LayoutInflater) context.getSystemService(Activity.LAYOUT_INFLATER_SERVICE);
		
		if(convertView == null){
			convertView = mInflater.inflate(R.layout.list_item, null);
			holder = new ViewHolder();
			holder.imageView = (ImageView) convertView.findViewById(R.id.icon);
			holder.textClave = (TextView) convertView.findViewById(R.id.title);
			convertView.setTag(holder);
		}
		else{
			holder = (ViewHolder) convertView.getTag();
		}
		List_paquete lp = (List_paquete)  getItem(position);
		holder.textClave.setText(lp.getClave());
		holder.imageView.setImageResource(lp.getImageId());
		return convertView;
	}

}
