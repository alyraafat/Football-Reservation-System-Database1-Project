﻿using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Milestone3
{
    public partial class CRRegister : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void crReg(object sender, EventArgs e)
        {
            String connStr = WebConfigurationManager.ConnectionStrings["FootballDB"].ToString();
            SqlConnection conn = new SqlConnection(connStr);
            String userName = username.Text;
            String passWord = password.Text;
            String Name = name.Text;
            String clubName = club.Text;
            String user = "SELECT * from SystemUser";
            SqlCommand allUsers = new SqlCommand(user, conn);
            SqlCommand addRep = new SqlCommand("addRepresentative", conn);
            addRep.CommandType = CommandType.StoredProcedure;
            addRep.Parameters.Add(new SqlParameter("@repName", Name));
            addRep.Parameters.Add(new SqlParameter("@password", passWord));
            addRep.Parameters.Add(new SqlParameter("@username", userName));
            addRep.Parameters.Add(new SqlParameter("@clubName", clubName));
            conn.Open();
            String clubSql = "SELECT * from allCLubs";
            SqlCommand allClub = new SqlCommand(clubSql, conn);
            String clubsWithNoRepSql = "SELECT * from allClubsWithNoRep";
            SqlCommand allClubsWithNoRep = new SqlCommand(clubsWithNoRepSql, conn);
            if (Name.Length > 20 || Name.Length == 0)
            {
                Response.Write("<script>alert('name is too long or empty');</script>");
            }
            else if (userName.Length > 20 || userName.Length == 0)
            {
                Response.Write("<script>alert('username is too long or empty');</script>");
            }
            else if (passWord.Length > 20 || passWord.Length == 0)
            {
                Response.Write("<script>alert('password is too long or empty');</script>");
            }
            else if (clubName.Length > 20 || clubName.Length == 0)
            {
                Response.Write("<script>alert('club name is too long or empty');</script>");
            }
            else
            {
                SqlDataReader userReader = allUsers.ExecuteReader();
                ArrayList UListUsernames = new ArrayList();
                ArrayList UListPassword = new ArrayList();
                while (userReader.Read())
                {
                    String resultusernames = userReader["username"].ToString();
                    String resultpasswords = userReader["password"].ToString();
                    UListUsernames.Add(resultusernames);
                    UListPassword.Add(resultpasswords);
                }
                userReader.Close();
                if (!UListUsernames.Contains(userName))
                {
                    SqlDataReader clubReader = allClub.ExecuteReader();
                    ArrayList CListNames = new ArrayList();
                    while (clubReader.Read())
                    {
                        String resultname = clubReader["name"].ToString();
                        CListNames.Add(resultname);
                    }
                    clubReader.Close();
                    if (!CListNames.Contains(clubName))
                    {
                        Response.Write("<script>alert('club does not exist')</script>");
                    }
                    else
                    {
                        SqlDataReader clubReader2 = allClubsWithNoRep.ExecuteReader();
                        ArrayList CListNamesWithNoManagers = new ArrayList();
                        while (clubReader2.Read())
                        {
                            String resultname = clubReader2["club_name"].ToString();
                            CListNamesWithNoManagers.Add(resultname);

                        }
                        clubReader2.Close();
                        if (!CListNamesWithNoManagers.Contains(clubName))
                        {
                            Response.Write("<script>alert('" + clubName + " has a representative already');</script>");
                        }
                        else
                        {
                            addRep.ExecuteNonQuery();
                            Session["user"] = userName;
                            Response.Redirect("Login.aspx");
                        }
                        
                    }
                }
                else
                {
                    Response.Write("<script>alert('existing username');</script>");
                }
            }
            conn.Close();
        }
    }
}