# Generated by Django 3.1.2 on 2020-10-25 17:30

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Attendance',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created', models.DateTimeField(auto_now_add=True)),
            ],
        ),
        migrations.CreateModel(
            name='Person',
            fields=[
                ('id', models.CharField(max_length=64, primary_key=True, serialize=False)),
                ('email', models.CharField(db_index=True, max_length=255)),
                ('name', models.CharField(max_length=255)),
            ],
        ),
        migrations.CreateModel(
            name='Lesson',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('lesson_id', models.CharField(db_index=True, max_length=255)),
                ('attended', models.ManyToManyField(related_name='lessons', through='api.Attendance', to='api.Person')),
                ('teacher', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='my_lessons', to='api.person')),
            ],
        ),
        migrations.AddField(
            model_name='attendance',
            name='lesson',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='attendance', to='api.lesson'),
        ),
        migrations.AddField(
            model_name='attendance',
            name='person',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='attendance', to='api.person'),
        ),
    ]
