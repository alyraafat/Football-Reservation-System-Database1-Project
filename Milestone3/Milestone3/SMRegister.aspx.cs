﻿using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Milestone3
{
    public partial class SMRegister : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void smReg(object sender, EventArgs e)
        {
            String connStr = WebConfigurationManager.ConnectionStrings["FootballDB"].ToString();
            SqlConnection conn = new SqlConnection(connStr);
            String userName = username.Text;
            String passWord = password.Text;
            String Name = name.Text;
            String stadiumName = stadium.Text;
            String user = "SELECT * from SystemUser";
            SqlCommand allUsers = new SqlCommand(user, conn);
            SqlCommand addSM = new SqlCommand("addStadiumManager", conn);
            addSM.CommandType = CommandType.StoredProcedure;
            addSM.Parameters.Add(new SqlParameter("@name", Name));
            addSM.Parameters.Add(new SqlParameter("@password", passWord));
            addSM.Parameters.Add(new SqlParameter("@username", userName));
            addSM.Parameters.Add(new SqlParameter("@stadiumName", stadiumName));
            conn.Open();

            String stadiumSql = "SELECT * from allStadiums";
            SqlCommand allStadium = new SqlCommand(stadiumSql, conn);
            String stadiumWithNoManagersSql = "SELECT * from allStadiumsWithNoManagers";
            SqlCommand allStadiumsWithNoManagers = new SqlCommand(stadiumWithNoManagersSql, conn);
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
            else if (stadiumName.Length > 20 || stadiumName.Length == 0)
            {
                Response.Write("<script>alert('stadium name is too long or empty');</script>");
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
                   SqlDataReader stadiumReader = allStadium.ExecuteReader();
                   ArrayList SListNames = new ArrayList();
                   while (stadiumReader.Read())
                   {
                        String resultname = stadiumReader["name"].ToString();
                        SListNames.Add(resultname);
                   }
                   stadiumReader.Close();
                   if (!SListNames.Contains(stadiumName))
                   {
                       Response.Write("<script>alert('stadium does not exist');</script>");
                   }
                   else
                   {
                        SqlDataReader stadiumReader2 = allStadiumsWithNoManagers.ExecuteReader();
                        ArrayList SListNamesWithNoManagers = new ArrayList();
                        while (stadiumReader2.Read())
                        {
                            String resultname = stadiumReader2["stadium_name"].ToString();
                            SListNamesWithNoManagers.Add(resultname);
                            
                        }
                        stadiumReader2.Close();
                        if (!SListNamesWithNoManagers.Contains(stadiumName))
                        {
                            Response.Write("<script>alert('"+stadiumName+" has a manager already');</script>");
                        }
                        else
                        {
                            addSM.ExecuteNonQuery();
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