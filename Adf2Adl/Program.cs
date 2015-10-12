using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Adf2Adl
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length != 2)
            {
                Console.WriteLine("Usage: Adf2Adl.exe <adf_file> <adl_file>");
                return;
            }

            string adfPath = args[0];
            string adlPath = args[1];
            ConvertSingleToDoubleSideAdfsImage(adfPath, adlPath);
        }

        private static void ConvertSingleToDoubleSideAdfsImage(string adfPath, string adlPath)
        {
            const int BBC_ADFS_TRACK_SIZE = 4096;
            using (FileStream outStream = new FileStream(adlPath, FileMode.Create, FileAccess.Write))
            using (FileStream inStream = new FileStream(adfPath, FileMode.Open, FileAccess.Read))
            {
                var buffer = new byte[BBC_ADFS_TRACK_SIZE];
                int bytes;
                while ((bytes = inStream.Read(buffer, 0, BBC_ADFS_TRACK_SIZE)) > 0)
                {
                    outStream.Write(buffer, 0, bytes);
                    outStream.Write(new byte[BBC_ADFS_TRACK_SIZE], 0, BBC_ADFS_TRACK_SIZE);
                }
            }
        }
    }
}
