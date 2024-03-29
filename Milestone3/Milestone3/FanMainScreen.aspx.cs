﻿using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Milestone3
{
    public partial class FanMainScreen : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }
        protected void onPurchaseClick(object sender, EventArgs e)
        {
            //try
            //{
            String username = Session["user"].ToString();
            //String username = "ahmed.amer2";
            String connStr = WebConfigurationManager.ConnectionStrings["FootballDB"].ToString();
            SqlConnection conn = new SqlConnection(connStr);

            String hostName = HostNameAddBox.Text;
            String guestName = GuestNameAddBox.Text;
            //DateTime startDateTime = new DateTime(Int32.Parse(startTimeYears.Text), Int32.Parse(startTimeMonth.Text), Int32.Parse(startTimeDay.Text), Int32.Parse(startTimeHours.Text), Int32.Parse(startTimeMinutes.Text), 0);

            DateTime startDateTime = DateTime.Parse(purchaseDate.Text);
            String date = startDateTime.ToString("yyyy-MM-dd HH:mm:ss");
            startDateTime = DateTime.Parse(date);

            String fan = "SELECT * from allFans";
            SqlCommand allFans = new SqlCommand(fan, conn);
            String match = "SELECT * from allMatches ";
            SqlCommand allMatch = new SqlCommand(match, conn);


            SqlCommand purchase = new SqlCommand("purchaseTicket", conn);
            purchase.CommandType = CommandType.StoredProcedure;

            purchase.Parameters.Add(new SqlParameter("@nameHostClub", hostName));
            purchase.Parameters.Add(new SqlParameter("@nameGuestClub", guestName));
            purchase.Parameters.Add(new SqlParameter("@startTime", startDateTime));
            conn.Open();
            SqlDataReader fanReader = allFans.ExecuteReader();
            String nationalId = "";
            String isBlocked = "";
            while (fanReader.Read())
            {
                String resultnatIds = fanReader["national_id"].ToString();
                if (fanReader["username"].ToString().Equals(username)) {
                    nationalId = resultnatIds;
                    isBlocked = fanReader["status"].ToString();
                    break;
                }
            }
            fanReader.Close();
            if (nationalId.Length == 0)
            {
                Response.Write("<script>alert('User not found');</script>");
            }
            else if (isBlocked.Equals("False")) {
                Response.Write("<script>alert('You are Blocked');</script>");
            }
            else
            {
                purchase.Parameters.Add(new SqlParameter("@nationalidnumber", nationalId));
                Boolean matchFound = false;
                SqlDataReader matchReader = allMatch.ExecuteReader();
                String resultTime = "";
                while (matchReader.Read())
                {
                    String resultHost = matchReader["host_club"].ToString();
                    String resultGuest = matchReader["guest_club"].ToString();
                    resultTime = matchReader["start_time"].ToString();
                    if (resultHost.Equals(hostName) && resultGuest.Equals(guestName))
                    {
                        if (resultTime.Equals(startDateTime.ToString()))
                        {
                            matchFound = true;
                            break;
                        }
                    }
                }
                matchReader.Close();

                if (matchFound)
                {
                    purchase.ExecuteNonQuery();
                    //Response.Write("<script>alert('" + isBlocked+ "');</script>");
                }
                else
                {
                    Response.Write("<script>alert('Match not found');</script>");
                }
                matchReader.Close();
                conn.Close();
            }  
            //}
            //catch (FormatException) {
            //    Response.Write("<script>alert('wrong date format');</script>");
           // }
        }

        protected void showAvailableMatches(object sender, EventArgs e)
        {
            String connStr = WebConfigurationManager.ConnectionStrings["FootballDB"].ToString();
            SqlConnection conn = new SqlConnection(connStr);
            //get available Matches
            if (dateOfAvailableMatches.Text.Length > 20 || dateOfAvailableMatches.Text.Length == 0)
            {
                Response.Write("<script>alert('date is too long or empty');</script>");
            }
            else
            {
                DateTime date = DateTime.Parse(dateOfAvailableMatches.Text);
                String date2 = date.ToString("yyyy-MM-dd HH:mm:ss");
                date = DateTime.Parse(date2);
                //if (!DateTime.TryParseExact(dateOfAvailableMatches.Text, "yyyy-MM-dd HH:mm:ss", CultureInfo.CurrentCulture, DateTimeStyles.None, out date))
               // {
                //    Response.Write("Write date in this format yyyy-mm-dd hh:mm:ss");
               // }
               // else
               // {
                conn.Open();
                SqlCommand getAvailableMatches = new SqlCommand("SELECT * FROM dbo.availableMatchesToAttend2(@datetime)", conn);
                getAvailableMatches.Parameters.AddWithValue("@datetime", date);
                SqlDataAdapter da = new SqlDataAdapter(getAvailableMatches);
                DataTable dt = new DataTable();
                da.Fill(dt);
                if (dt.Rows.Count == 0)
                {
                    Label empty = new Label();
                    empty.Text = "No available Matches";
                    form1.Controls.Add(empty);
                }
                else
                {
                    availableMatches.DataSource = dt;
                    availableMatches.DataBind();
                }
                   
                conn.Close();
               // }
            }
        }
    }
}