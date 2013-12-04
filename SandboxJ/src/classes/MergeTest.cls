global class MergeTest
{ public static boolean MergeRecords(Contact[] c)
  { if(c.size()>2) return false;
    if(c[1].HasOptedOutOfEmail)
      c[0].HasOptedOutOfEmail = true;
    merge c[0] c[1];
    return true;
  }
  public static testMethod void testMergeRecords()
  { Contact[] cs = new Contact[2];
    cs[0] = new Contact(FirstName='Brian',LastName='Fear');
    cs[1] = new Contact(FirstName='Brian',LastName='Fear',HasOptedOutOfEmail=true);
    insert cs;
    System.assert(MergeRecords(cs));
    delete cs[0];
  }
}