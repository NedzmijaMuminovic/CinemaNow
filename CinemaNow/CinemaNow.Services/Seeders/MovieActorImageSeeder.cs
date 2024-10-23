using CinemaNow.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Hosting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services.Seeders
{
    public class MovieActorImageSeeder : IMovieActorImageSeeder
    {
        private readonly Ib200033Context _context;
        private readonly string _imageFolderPath;

        public MovieActorImageSeeder(Ib200033Context context, string imageFolderPath)
        {
            _context = context;
            _imageFolderPath = imageFolderPath;
        }

        public async Task SeedMovieActorImages()
        {
            var movies = await _context.Movies.Where(m => m.Image == null).ToListAsync();
            var actors = await _context.Actors.Where(a => a.Image == null).ToListAsync();

            foreach (var movie in movies)
            {
                var imagePath = Path.Combine(_imageFolderPath, $"movie_{movie.Id}.jpg");
                if (File.Exists(imagePath))
                {
                    movie.Image = await File.ReadAllBytesAsync(imagePath);
                }
            }

            foreach (var actor in actors)
            {
                var imagePath = Path.Combine(_imageFolderPath, $"actor_{actor.Id}.jpg");
                if (File.Exists(imagePath))
                {
                    actor.Image = await File.ReadAllBytesAsync(imagePath);
                }
            }

            await _context.SaveChangesAsync();
        }
    }

}
